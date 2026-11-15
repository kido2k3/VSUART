//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_brg_boundary_seq (virtual sequence)
//-- Description    : F2.3.2.x baud rate generation at BRG = 1 / 65535 / 0
//-- History        : ver.1.00 (26/11/13) 1st release
//===========================================================================
class vsuart_brg_boundary_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_brg_boundary_seq)

    function new(string name = "vsuart_brg_boundary_seq");
        super.new(name);
    endfunction

    // task: program BSEL/BRG, send one random character, wait TX done
    task boundary_step(bit bsel, bit [15:0] brg);

        uart_disable();
        check_uen_disabled();
        ral.MODE.BSEL.set(bsel);
        ral.BRG.BRG.set(brg);
        update_reg(ral.MODE);
        update_reg(ral.BRG);
        check_field(ral.BRG.BRG, brg);
        uart_enable();
        sva_vif.target_baud = 0;   
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

        // F2.3.2.1: BRG = 1 (max rate), 4x then 16x
        boundary_step(1'b1, 16'd1);
        boundary_step(1'b0, 16'd1);
        // F2.3.2.2: BRG = 65535 (min rate), 16x
        boundary_step(1'b0, 16'hFFFF);
        // F2.3.2.3: BRG = 0 is written, read back as 0 and TX still completes
        // (a hang ends in the UVM timeout)
        boundary_step(1'b0, 16'h0000);

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
