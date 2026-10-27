//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_scb (vsuart scoreboard)
//-- History        : ver.1.00 (26/10/24) 1st release
//===========================================================================
`uvm_analysis_imp_decl(_apb_mst)
`uvm_analysis_imp_decl(_uart_tx)
`uvm_analysis_imp_decl(_uart_rx)
`uvm_analysis_imp_decl(_ifs)
`uvm_analysis_imp_decl(_rst)
class vsuart_scb extends uvm_scoreboard;

    `uvm_component_utils(vsuart_scb)
    // address of data (fifo)
    localparam bit [15:0] DATA_ADDR = 16'hffff;
    // all analysis port
    uvm_analysis_imp_apb_mst #(_apb_item, vsuart_scb) apb_mst_ap_imp;
    uvm_analysis_imp_uart_tx #(uart_item, vsuart_scb) uart_tx_ap_imp;
    uvm_analysis_imp_uart_rx #(uart_item, vsuart_scb) uart_rx_ap_imp;
    uvm_analysis_imp_ifs #(ifs_item, vsuart_scb) ifs_ap_imp;
    uvm_analysis_imp_rst #(rst_item, vsuart_scb) rst_ap_imp;
    // uart cfg: to get data width for compare mask
    uart_cfg u_cfg;
    
    // queue of data
    mailbox #(_apb_item) mb_apb_wr_data;    // apb write -> expect on uart tx
    mailbox #(_apb_item) mb_apb_rd_data;    // apb read  -> expect from uart rx
    mailbox #(uart_item) mb_uart_tx_data;
    mailbox #(uart_item) mb_uart_rx_data;

    // run phase handle: keep test alive while tx frame is pending
    uvm_phase run_ph;
    int tx_pending;

    // reset event: restart compare threads
    event rst_ev;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // get uart cfg
        if (! uvm_config_db #(uart_cfg) :: get (this, "", "uart_cfg", u_cfg)) begin
            `uvm_fatal ("NOT_CFG", "UART configured not found")
        end
        // create analysis port
        apb_mst_ap_imp = new("apb_mst_ap_imp", this);
        uart_tx_ap_imp = new("uart_tx_ap_imp", this);
        uart_rx_ap_imp = new("uart_rx_ap_imp", this);
        ifs_ap_imp = new("ifs_ap_imp", this);
        rst_ap_imp = new("rst_ap_imp", this);
        // create queue
        mb_apb_wr_data = new();
        mb_apb_rd_data = new();
        mb_uart_tx_data = new();
        mb_uart_rx_data = new();
    endfunction

    task run_phase(uvm_phase phase);
        run_ph = phase;
        forever begin
            fork
                //full duplex, checking tx and rx simultaneously 
                tx_cmp();
                rx_cmp();
                @(rst_ev);// reset: drop item already taken
            join_any
            disable fork;
        end
    endtask

    // task: apb write data vs uart tx frame
    task tx_cmp();
        _apb_item apb;
        uart_item uart;
        forever begin
            mb_apb_wr_data.get(apb);
            mb_uart_tx_data.get(uart);
            data_cmp("TX", apb, uart);
            if (tx_pending > 0) begin
                tx_pending--;
                run_ph.drop_objection(this, "tx frame compared");
            end
        end
    endtask

    // uart rx frame vs apb read data
    task rx_cmp();
        _apb_item apb;
        uart_item uart;
        forever begin
            mb_apb_rd_data.get(apb);
            mb_uart_rx_data.get(uart);
            data_cmp("RX", apb, uart);
        end
    endtask

    // compare data with data width mask
    function void data_cmp(string dir, _apb_item apb, uart_item uart);
        bit [8:0] mask = (u_cfg.data_width == UART_DATA_9) ? 9'h1ff : 9'h0ff;
        bit [8:0] apb_data = apb.data[8:0] & mask;
        bit [8:0] uart_data = uart.data & mask;
        if (apb_data == uart_data) begin
            `uvm_info($sformatf("SCB %s", dir), $sformatf("MATCH apb=0x%03h uart=0x%03h", apb_data, uart_data), UVM_LOW)
        end else begin
            `uvm_error($sformatf("SCB %s", dir), $sformatf("MISMATCH apb=0x%03h uart=0x%03h", apb_data, uart_data))
        end
    endfunction

    // handle data received from apb monitor
    virtual function void write_apb_mst(_apb_item rcv_item);
        `uvm_info("SCB apb mst", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        
        // only data access, skip transfer aborted by reset
        if (rcv_item.addr != DATA_ADDR) return;

        //Write trans
        if (rcv_item.trans_type == _apb_item::WRITE) begin
            void'(mb_apb_wr_data.try_put(rcv_item));
            // hold the test until the frame is sent on tx
            if (run_ph != null) begin
                tx_pending++;
                run_ph.raise_objection(this, "tx frame pending");
            end
        end else if (!rcv_item.slverr) begin //Recevie trans
            void'(mb_apb_rd_data.try_put(rcv_item));
        end
    endfunction

    // function: handle data received from uart TX monitor
    virtual function void write_uart_tx(uart_item rcv_item);
        `uvm_info("SCB uart tx", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        void'(mb_uart_tx_data.try_put(rcv_item));
    endfunction

    // function: handle data received from uart RX monitor
    virtual function void write_uart_rx(uart_item rcv_item);
        `uvm_info("SCB uart rx", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        
        void'(mb_uart_rx_data.try_put(rcv_item));
    endfunction

    // function: handle data received from ifs monitor
    virtual function void write_ifs(ifs_item rcv_item);
    endfunction

    // function: handle data received from clk_rst monitor
    // reset clears dut fifo -> drop all pending data
    virtual function void write_rst(rst_item rcv_item);
        _apb_item apb;
        uart_item uart;
        while (mb_apb_wr_data.try_get(apb));
        while (mb_apb_rd_data.try_get(apb));
        while (mb_uart_tx_data.try_get(uart));
        while (mb_uart_rx_data.try_get(uart));
        if (tx_pending > 0) begin
            run_ph.drop_objection(this, "reset", tx_pending);
            tx_pending = 0;
        end
        -> rst_ev;
    endfunction

    // check: no data left at end of test
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (mb_apb_wr_data.num() != 0 || mb_uart_tx_data.num() != 0)
            `uvm_error("SCB TX", $sformatf("data left: apb_wr=%0d uart_tx=%0d", mb_apb_wr_data.num(), mb_uart_tx_data.num()))
        if (mb_apb_rd_data.num() != 0)
            `uvm_error("SCB RX", $sformatf("data left: apb_rd=%0d", mb_apb_rd_data.num()))
        // frames still in rx fifo (not read by apb) are only reported
        if (mb_uart_rx_data.num() != 0)
            `uvm_warning("SCB RX", $sformatf("%0d RX frame(s) not compared with an APB read", mb_uart_rx_data.num()))
    endfunction

endclass
