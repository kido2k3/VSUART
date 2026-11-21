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
    uvm_analysis_imp_ifs #(irq_item, vsuart_scb) ifs_ap_imp;
    uvm_analysis_imp_rst #(rst_item, vsuart_scb) rst_ap_imp;
    
    vsuart_cfg cfg;
    ral_blk    ral;   // register model, set by vsuart_env (connect_phase)

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

    // TX enable model (MODE.UEN[0] & UEN[2], from APB writes). Disabling TX
    // aborts the frame on the line and resets TX FIFO; FIFO writes are
    // ignored while TX is disabled.
    bit   tx_en;
    time  tx_abort_time;      // frames started before this were aborted
    event tx_flush_ev;        // restart tx_cmp

    // RX enable model (MODE.UEN[1] & UEN[2]). Disabling RX aborts the frame
    // on the line and resets RX FIFO (spec sec. 4 "Enabling UART").
    // A frame is received only if RX was enabled for its whole duration.
    bit   rx_en;
    time  rx_abort_time;      // last RX enable 1 -> 0

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
        mb_apb_wr_data = new(`FIFO_DEPTH);
        mb_apb_rd_data = new();
        mb_uart_tx_data = new();
        mb_uart_rx_data = new(`FIFO_DEPTH);
    endfunction

    task run_phase(uvm_phase phase);
        run_ph = phase;
        if (ral == null) `uvm_fatal("NOT_RAL", "register model not set in scb")
        //full duplex, checking tx and rx simultaneously
        fork
            forever begin
                fork
                    tx_cmp();
                    @(rst_ev or tx_flush_ev);// reset / TX disable: drop item already taken
                join_any
                disable fork;
            end
            forever begin
                fork
                    rx_cmp();
                    @(rst_ev);// reset: drop item already taken
                join_any
                disable fork;
            end
        join
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
        // MODE.UEN write (byte lane 0)
        if (rcv_item.trans_type == _apb_item::WRITE && rcv_item.addr == ral.MODE.get_address()
            && rcv_item.strb[0]) begin
            // mirror already updated: reg_env.pred is written before scb (imp order by name)
            uvm_reg_data_t uen = ral.MODE.UEN.get_mirrored_value();
            update_tx_en(uen[0] & uen[2]);
            update_rx_en(uen[1] & uen[2]);
        end

        // only data access
        if (rcv_item.addr != DATA_ADDR) return; 

        //Write trans
        if (rcv_item.trans_type == _apb_item::WRITE) begin
            if (!tx_en) begin
                `uvm_info("SCB TX", $sformatf("TX disabled, FIFO write 0x%03h ignored", rcv_item.data[8:0]), UVM_LOW)
                return;
            end
            if (!mb_apb_wr_data.try_put(rcv_item)) begin
                `uvm_info("SCB TX", $sformatf("TX FIFO full (%0d), dropping overflow frame data=0x%03h",  `FIFO_DEPTH, rcv_item.data), UVM_LOW)
                return;  
            end
            // hold the test until the frame is sent on tx
            if (run_ph != null) begin
                tx_pending++;
                run_ph.raise_objection(this, "tx frame pending");
            end
        end else begin //Recevie trans
            void'(mb_apb_rd_data.try_put(rcv_item));
        end
    endfunction

    // function: TX enable 1 -> 0 drops every pending TX character
    function void update_tx_en(bit en);
        if (tx_en && !en) begin
            _apb_item apb;
            int n = mb_apb_wr_data.num(); //display number discard transaction
            while (mb_apb_wr_data.try_get(apb));
            if (tx_pending > 0) begin
                n = tx_pending;   // includes the item held by tx_cmp
                run_ph.drop_objection(this, "tx disabled", tx_pending);
                tx_pending = 0;
            end
            tx_abort_time        = $time;
            previous_end_time[1] = 0;
            -> tx_flush_ev;
            `uvm_info("SCB TX", $sformatf("TX disabled, %0d pending character(s) dropped", n), UVM_LOW)
        end
        tx_en = en;
    endfunction

    // function: RX enable 1 -> 0 resets RX FIFO (spec) -> drop stored frames
    function void update_rx_en(bit en);
        if (rx_en && !en) begin
            uart_item uart;
            int n = mb_uart_rx_data.num();
            while (mb_uart_rx_data.try_get(uart));
            rx_abort_time        = $time;
            previous_end_time[0] = 0;
            `uvm_info("SCB RX", $sformatf("RX disabled, RX FIFO reset: %0d stored frame(s) dropped", n), UVM_LOW)
        end
        rx_en = en;
    endfunction

    function void check_uart_errors(string dir, uart_item item);
        if (cfg.check_parity_error && item.parity_error)
            `uvm_error("SCB_UART_PARITY", $sformatf("UART %s parity error: data=0x%03h", dir, item.data))
        if (cfg.check_frame_error && item.frame_error)
            `uvm_error("SCB_UART_FRAME", $sformatf("UART %s frame error: data=0x%03h", dir, item.data))
    endfunction

    // function: check continuous frames must follow each other
    function void check_uart_continuity(bit is_tx, uart_item item);
        string   dir = is_tx ? "TX" : "RX";
        realtime bit_period, gap;

        if (!cfg.enable_continous) begin
            previous_end_time = '{default: 0};
            return;
        end

        // bypass first frame
        if (previous_end_time[is_tx] != 0) begin
            // bit period 
            bit_period = 1s / cfg.u_cfg.baudrate;
            gap        = (item.start_time > previous_end_time[is_tx])
                       ? item.start_time - previous_end_time[is_tx]
                       : previous_end_time[is_tx] - item.start_time;

            if (gap > cfg.tolerance * bit_period)
                `uvm_error("SCB_UART_CONTINUITY", $sformatf(
                    "UART %s not continuous: previous_end=%0t start=%0t gap=%0.3f bit (max %0.3f)",
                    dir, previous_end_time[is_tx], item.start_time,
                    gap / bit_period, cfg.tolerance))
        end
        previous_end_time[is_tx] = item.end_time;
    endfunction

    // handle data received from uart TX monitor and write data to uart_tx mail box
    virtual function void write_uart_tx(uart_item rcv_item);
        `uvm_info("SCB uart tx", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        // frame cut by a TX disable: the monitor still samples it to the end
        if (rcv_item.start_time < tx_abort_time) begin
            `uvm_info("SCB TX", $sformatf("aborted frame dropped (start=%0t, TX disabled at %0t)",
                      rcv_item.start_time, tx_abort_time), UVM_LOW)
            return;
        end
        check_uart_errors("TX", rcv_item);
        check_uart_continuity(1'b1, rcv_item);
        void'(mb_uart_tx_data.try_put(rcv_item));
    endfunction

    // function: handle data received from uart RX monitor and write data to uart_rx mail box
    virtual function void write_uart_rx(uart_item rcv_item);
        `uvm_info("SCB uart rx", $sformatf("received data:%s", rcv_item.sprint), UVM_HIGH)
        // RX disabled at any point of the frame: DUT does not receive it
        if (!rx_en || rcv_item.start_time < rx_abort_time) begin
            `uvm_info("SCB RX", $sformatf("RX disabled, frame dropped data=0x%03h (start=%0t)",
                      rcv_item.data, rcv_item.start_time), UVM_LOW)
            return;
        end
        check_uart_errors("RX", rcv_item);
        check_uart_continuity(1'b0, rcv_item);
        // DUT writes RX FIFO only for frames without parity/frame error
        if (rcv_item.parity_error || rcv_item.frame_error) begin
            `uvm_info("SCB RX", $sformatf("error frame not stored in RX FIFO data=0x%03h (parity_err=%0b frame_err=%0b)",
                      rcv_item.data, rcv_item.parity_error, rcv_item.frame_error), UVM_LOW)
            return;
        end
        if (!mb_uart_rx_data.try_put(rcv_item)) begin
            `uvm_info("SCB RX", $sformatf("RX FIFO full (%0d), dropping overflow frame data=0x%03h",  `FIFO_DEPTH, rcv_item.data), UVM_LOW)
        end
    endfunction

    // function: handle data received from ifs monitor
    virtual function void write_ifs(irq_item rcv_item);
    endfunction

    // function: handle data received from clk_rst monitor
    // reset clears dut fifo -> drop all pending data
    virtual function void write_rst(rst_item rcv_item);
        _apb_item apb;
        uart_item uart;
        previous_end_time[0] = 0;
        previous_end_time[1] = 0;
        tx_en         = 0;      // MODE resets to 0
        tx_abort_time = $time;
        rx_en         = 0;
        rx_abort_time = $time;
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