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
    
    vsuart_cfg cfg;
    
    // queue of data
    mailbox #(_apb_item) mb_apb_wr_data;    // apb write -> expect on uart tx
    mailbox #(_apb_item) mb_apb_rd_data;    // apb read  -> expect from uart rx
    mailbox #(uart_item) mb_uart_tx_data;
    mailbox #(uart_item) mb_uart_rx_data;

    // run phase handle: keep test alive while tx frame is pending
    uvm_phase run_ph;
    int tx_pending;

    // contain end time of previous transaction index 0 = RX, index 1 = TX.
    time previous_end_time[2] = '{default: 0};

    // reset event: restart compare threads
    event rst_ev;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(vsuart_cfg)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOT_CFG", "VSUART configuration not found")
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
        bit [8:0] mask = (cfg.u_cfg.data_width == UART_DATA_9) ? 9'h1ff : 9'h0ff;
        bit [8:0] apb_data = apb.data[8:0] & mask;
        bit [8:0] uart_data = uart.data & mask;
        if (apb_data == uart_data) begin
            `uvm_info($sformatf("SCB %s", dir), $sformatf("MATCH apb=0x%03h uart=0x%03h", apb_data, uart_data), UVM_LOW)
        end else begin
            `uvm_error($sformatf("SCB %s", dir), $sformatf("MISMATCH apb=0x%03h uart=0x%03h", apb_data, uart_data))
        end
    endfunction

    // handle data received from apb monitor and write data to apb mailbox
    virtual function void write_apb_mst(_apb_item rcv_item);
        `uvm_info("SCB apb mst", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        
        // Optionally report errors; failed accesses must not enter data queues.
        if (rcv_item.slverr) begin
            if (cfg.check_pslverr) begin
                `uvm_error("SCB_APB_SLVERR", $sformatf("APB %s slave error: addr=0x%04h data=0x%08h",
                           rcv_item.trans_type.name(), rcv_item.addr, rcv_item.data))
            end
            return;
        end

        // only data access
        if (rcv_item.addr != DATA_ADDR) return; 

        //Write trans
        if (rcv_item.trans_type == _apb_item::WRITE) begin
            void'(mb_apb_wr_data.try_put(rcv_item));
            // hold the test until the frame is sent on tx
            if (run_ph != null) begin
                tx_pending++;
                run_ph.raise_objection(this, "tx frame pending");
            end
        end else begin //Recevie trans
            void'(mb_apb_rd_data.try_put(rcv_item));
        end
    endfunction

    function void check_uart_errors(string dir, uart_item item);
        if (cfg.check_parity_error && item.parity_error)
            `uvm_error("SCB_UART_PARITY", $sformatf("UART %s parity error: data=0x%03h", dir, item.data))
        if (cfg.check_frame_error && item.frame_error)
            `uvm_error("SCB_UART_FRAME", $sformatf("UART %s frame error: data=0x%03h", dir, item.data))
    endfunction

    function automatic int unsigned abs_int(int val);
    return (val < 0) ? -val : val;
    endfunction

    function void check_uart_continuity(bit is_tx, uart_item item);
        string dir;
        dir = is_tx ? "TX" : "RX";
        if (!cfg.enable_continous) begin
            previous_end_time[0] = 0;
            previous_end_time[1] = 0;
            return;
        end
        if (previous_end_time[is_tx] != 0) begin
            // Continuous frames must meet exactly, with no gap or overlap.
            int temp = item.start_time - previous_end_time[is_tx];
            temp = abs_int(temp);
            if (temp*1.0 / (1.0/cfg.u_cfg.baudrate) > cfg.tolerance)
                `uvm_error("SCB_UART_CONTINUITY", $sformatf(
                    "UART %s not continuous: previous_end=%0t start=%0t (expected exact equality)",
                    dir, previous_end_time[is_tx], item.start_time))
        end
        previous_end_time[is_tx] = item.end_time;
    endfunction

    // handle data received from uart TX monitor and write data to uart_tx mail box
    virtual function void write_uart_tx(uart_item rcv_item);
        `uvm_info("SCB uart tx", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        check_uart_errors("TX", rcv_item);
        check_uart_continuity(1'b1, rcv_item);
        void'(mb_uart_tx_data.try_put(rcv_item));
    endfunction

    // function: handle data received from uart RX monitor and write data to uart_rx mail box
    virtual function void write_uart_rx(uart_item rcv_item);
        `uvm_info("SCB uart rx", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        check_uart_errors("RX", rcv_item);
        check_uart_continuity(1'b0, rcv_item);
        
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
        previous_end_time[0] = 0;
        previous_end_time[1] = 0;
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
