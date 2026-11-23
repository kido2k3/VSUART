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

    int unsigned nom_baud   = 9600;
    real         mismatch   = 2.0;
    int unsigned num_frames = 10;

    // data sent on rx 
    uvm_reg_data_t sent_q[$];

    function new(string name = "vsuart_rx_baud_mismatch_seq");
        super.new(name);
    endfunction

    protected function uvm_reg_data_t get_sent_data();
        bit [8:0] d = uart_seq.seq_item.data;
        if (cfg.u_cfg.data_width != UART_DATA_9) d[8] = 1'b0;
        return uvm_reg_data_t'(d);
    endfunction

    // task: UEN=0 -> BSEL/BRG for nom_baud -> read back -> UEN=3'b111
    task set_dut_baud(bit bsel);
        int unsigned os     = bsel ? 4 : 16;
        int unsigned sys_hz = cfg.c_cfg._sys_freq * 1_000_000;
        bit [15:0]   brg    = 16'((sys_hz + os * nom_baud / 2) / (os * nom_baud) - 1);

        uart_disable();
        check_uen_disabled();
        ral.MODE.BSEL.set(bsel);
        ral.BRG.BRG.set(brg);
        update_reg(ral.MODE);
        update_reg(ral.BRG);
        check_field(ral.MODE.BSEL, bsel);
        check_field(ral.BRG.BRG, brg);
        uart_enable();
        check_field(ral.MODE.UEN, 3'b111);
    endtask

    task set_agent_baud(real period_err);
        int unsigned baud = int'($rtoi(real'(nom_baud) / (1.0 + period_err) + 0.5)); // calculate for clks_per_bit_cal()
        cfg.u_cfg.baudrate = baud;
        cfg.u_cfg.clks_per_bit_cal();
        uvm_config_db #(vsuart_cfg) :: set (null, "*", "cfg", cfg);
        sva_vif.target_baud = 0; // agent baud differs from the DUT baud on purpose, no TX baud check
        `uvm_info(get_type_name, $sformatf("agent baud=%0d (rx bit period %s%0.1f%% vs %0d bps)",baud, (period_err < 0.0) ? "-" : "+",
                  (period_err < 0.0) ? -period_err * 100.0 : period_err * 100.0,
                  nom_baud), UVM_LOW)
    endtask

    task rx_case(string tag, real period_err);
        uvm_reg_data_t actual, sta;

        set_agent_baud(period_err);
        sent_q.delete();

        // send frames on rx
        repeat (num_frames) begin
            uart_wdata();
            sent_q.push_back(get_sent_data());
        end
        wait_field(ral.STA.RISTA, 1);   // receiver back to idle

        // read RX FIFO and compare
        foreach (sent_q[i]) begin
            wait_rx_fifo_not_empty();
            read_rx_data(actual);
            if (actual !== sent_q[i])
                `uvm_error("RX_DATA", $sformatf("[%s] frame %0d: read=0x%0h sent=0x%0h",
                           tag, i, actual, sent_q[i]))
        end

        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.RBDSTA, 0);
        expect_field(sta, ral.STA.FRERR,  0);
        expect_field(sta, ral.STA.PRERR,  0);
        expect_field(sta, ral.STA.RBOSTA, 0);
        check_irq("EV_ERR_IRQ", 0);
        clear_irq(ral.IFS.RXIFS);
        check_irq("EV_RX_IRQ", 0);
    endtask

    task run_both(string round);
        rx_case({round, "_shorter"}, -mismatch / 100.0);   // bit period 2% shorter
        rx_case({round, "_longer"},  +mismatch / 100.0);   // bit period 2% longer
    endtask

    virtual task body();
        if (cfg == null || ral == null)
            `uvm_fatal("RXMM_SETUP", "cfg/ral not connected")
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)

        // Power On Reset ,Default Register 
        init_rst(13, 10000);
        config_default();

        // round 0: default register
        run_both("default");

        // round 1: UEN=3'b000 -> BSEL=0 and BRG for 9600 bps -> UEN=3'b111
        set_dut_baud(1'b0);
        run_both("bsel0");

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass