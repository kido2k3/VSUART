//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_brg_boundary_seq (virtual sequence)
//-- Description    : F2.3.2.x baud rate generation at BRG = 65535 (min) / 0 (max)
//-- History        : ver.1.00 (26/11/13) 1st release
//===========================================================================
class vsuart_brg_boundary_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_brg_boundary_seq)

    function new(string name = "vsuart_brg_boundary_seq");
        super.new(name);
    endfunction

    // task: program BSEL/BRG, send one random character, wait TX done
    task boundary_step(bit bsel, bit [15:0] brg);
        int unsigned sys_hz = cfg.c_cfg._sys_freq * 1_000_000;
        int unsigned cpb    = bit_time(bsel, brg);           // sys_clk cycles per bit
        int unsigned baud   = (sys_hz + cpb / 2) / cpb;      // DUT baud rate, rounded

        uart_disable();
        check_uen_disabled();
        ral.MODE.BSEL.set(bsel);
        ral.BRG.BRG.set(brg);
        update_reg(ral.MODE);
        update_reg(ral.BRG);
        check_field(ral.BRG.BRG, brg);
        uart_enable();

        // uart agent: clks_per_bit is in uart_clk cycles, recalculated from baud
        cfg.u_cfg.baudrate = baud;
        cfg.u_cfg.clks_per_bit_cal();
        uvm_config_db #(vsuart_cfg) :: set (null, "*", "cfg", cfg);
        // SVA A_TX_BAUD checks the bit time on sys_clk
        sva_vif.target_baud = baud;

        apb_wr_data();

        wait_field(ral.STA.TRSTA, 0);
        wait_field(ral.STA.TRSTA, 1);
    endtask

    virtual task body();
        if (cfg == null || ral == null)
            `uvm_fatal("BRG_SETUP", "cfg/ral not connected")
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)

        // Power On Reset; program registers as in 6. Default Register
        init_rst(13, 10000);
        config_default();

        // F2.3.2.2: BRG = 65535 (min rate), 16x
        boundary_step(1'b0, 16'hFFFF);
        // F2.3.2.1: BRG = 0 (max rate), 16x
        boundary_step(1'b0, 16'h0000);
        // F2.3.2.1: BRG = 0 (max rate), 4x
        boundary_step(1'b1, 16'h0000);

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
