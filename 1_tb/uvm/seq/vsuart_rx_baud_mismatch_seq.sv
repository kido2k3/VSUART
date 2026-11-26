//===========================================================================
//-- Author         : 
//-- Name           : vsuart_rx_baud_mismatch_seq (virtual sequence)
//-- Description    : RX reception with +-2% baud rate mismatch
//--                  Case A: rx bit period 2% shorter (baud faster)
//--                  Case B: rx bit period 2% longer  (baud slower)
//-- History        : ver.1.00 (26/11/23) 1st release
//===========================================================================
class vsuart_rx_baud_mismatch_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_baud_mismatch_seq)

    real         mismatch   = 2.0;   // percent
    int unsigned num_frames = 3;

    // data sent on rx
    uvm_reg_data_t sent_q[$];

    function new(string name = "vsuart_rx_baud_mismatch_seq");
        super.new(name);
    endfunction

    protected function uvm_reg_data_t get_sent_data();
        bit [8:0] d;
        d = uart_seq.seq_item.data;
        if (cfg.u_cfg.data_width != UART_DATA_9) d[8] = 1'b0;
        return uvm_reg_data_t'(d);
    endfunction

    task set_agent_baud(real period_err, int unsigned nominal_baud);
        int unsigned agent_baud;
        agent_baud = int'($rtoi(real'(nominal_baud) / (1.0 + period_err) + 0.5));
        cfg.u_cfg.baudrate = agent_baud;     
        cfg.u_cfg.clks_per_bit_cal();
        uvm_config_db #(vsuart_cfg)::set(null, "*", "cfg", cfg);

        `uvm_info(get_type_name(),
            $sformatf("agent baud=%0d (rx bit period %s%0.1f%% vs %0d bps)",
                      agent_baud,
                      (period_err < 0.0) ? "-" : "+",
                      (period_err < 0.0) ? -period_err * 100.0 : period_err * 100.0,
                      nominal_baud), UVM_LOW)
    endtask

    task rx_case(string tag, real period_err, int unsigned nominal_baud);
        uvm_reg_data_t actual ,sta;

        set_agent_baud(period_err, nominal_baud);
        sent_q.delete();

        repeat (num_frames) begin
         uart_wdata();
         sent_q.push_back(get_sent_data());
         end
        wait_field(ral.STA.RISTA, 1);   // receiver back to idle

        foreach (sent_q[i]) begin
            wait_rx_fifo_not_empty();
            read_rx_data(actual);
            `uvm_info("RX_DATA", $sformatf("[%s] frame %0d: read=0x%0h sent=0x%0h",
                           tag, i, actual, sent_q[i]), UVM_LOW)
        end

        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.RBDSTA, 0);
        expect_field(sta, ral.STA.FRERR,  0);
        expect_field(sta, ral.STA.PRERR,  0);
        expect_field(sta, ral.STA.RBOSTA, 0);
        check_irq(EV_ERR_IRQ, 0);
        clear_irq(ral.IFS.RXIFS);
        check_field(ral.IFS.RXIFS, 0);
        check_irq(EV_RX_IRQ, 0);
    endtask
    
    task run_both(string round, int unsigned nominal_baud);
        rx_case({round, "_shorter"}, -mismatch / 100.0, nominal_baud); // chu ky ngan hon 2%
        rx_case({round, "_longer"},  +mismatch / 100.0, nominal_baud); // chu ky dai hon 2%
    endtask

    virtual task body();
        if (cfg == null || ral == null)
            `uvm_fatal("RXMM_SETUP", "cfg/ral not connected")
        `uvm_info(get_type_name(), "Body entered...", UVM_LOW)

        // Power On Reset, Default Register
        init_rst(13, 10000);
        config_default();

        for (int b = 0; b < 2; b++) begin
            foreach (bauds[i]) begin
                set_dut_baud(b, bauds[i]);
                run_both({b ? "bsel1_" : "bsel0_", $sformatf("%0d", bauds[i])}, bauds[i]);
            end
        end

        `uvm_info(get_type_name(), "Body end...", UVM_LOW)
    endtask
endclass