//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_brg_range_seq (virtual sequence)
//-- Description    : F2.3.1.x TX baud rate at the standard rates, BSEL = 0 / 1
//-- History        : ver.1.00 (26/11/13) 1st release
//===========================================================================
class vsuart_brg_range_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_brg_range_seq)

    int unsigned bauds[] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

    function new(string name = "vsuart_brg_range_seq");
        super.new(name);
    endfunction

    // task: program BSEL/BRG for the baud, send 2 characters 
    task range_step(bit bsel, int unsigned baud);
        int unsigned os     = bsel ? 4 : 16;
        int unsigned sys_hz = cfg.c_cfg._sys_freq * 1_000_000;
        // BRG = (Fsys_clk / (OS * baud) - 1   
        bit [15:0]   brg    = 16'((sys_hz + os * baud / 2) / (os * baud) - 1);

        // UEN = 0 -> BSEL/BRG -> read BRG back -> UEN = 1
        uart_disable();
        check_uen_disabled();
        ral.MODE.BSEL.set(bsel);
        ral.BRG.BRG.set(brg);
        update_reg(ral.MODE);
        update_reg(ral.BRG);
        check_field(ral.BRG.BRG, brg);
        uart_enable();
        sva_vif.target_baud = baud;

        
        repeat (2) apb_wr_data();

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

        for (int b = 0; b < 2; b++)
            foreach (bauds[i])
                range_step(b, bauds[i]);

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
