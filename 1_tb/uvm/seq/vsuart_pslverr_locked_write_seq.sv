//=====================================================================
//-- Author      : trizrd
//-- Name        : vsuart_pslverr_locked_write_seq (virtual sequence)
//-- Description : F2.1.2.1 PSLVERR when protected registers (BRG, MODE.BSEL/PDSEL/SPSEL)
//                 are written while the UART is enabled
//-- History     : ver.1.00 (26/11/18) 1st release
//=====================================================================
class vsuart_pslverr_locked_write_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_pslverr_locked_write_seq)

    function new(string name = "vsuart_pslverr_locked_write_seq");
        super.new(name);
    endfunction

    // function: new random desired values for BRG and MODE (BSEL, PDSEL, SPSEL),
    // all different from the current ones (so a write that slips through is visible)
    protected function void rand_new();
        uvm_reg_data_t old_brg   = ral.BRG.BRG.get_mirrored_value();
        uvm_reg_data_t old_bsel  = ral.MODE.BSEL.get_mirrored_value();
        uvm_reg_data_t old_pdsel = ral.MODE.PDSEL.get_mirrored_value();
        uvm_reg_data_t old_spsel = ral.MODE.SPSEL.get_mirrored_value();
        uvm_reg_data_t cur_uen   = ral.MODE.UEN.get_mirrored_value();

        // BRG = 0 is not allowed
        assert(ral.BRG.randomize() with { BRG.value != 0; BRG.value != local::old_brg; });
        // UEN is kept: it is not part of the protected fields (changed later on its own)
        assert(ral.MODE.randomize() with { UEN.value   == local::cur_uen;
                                           BSEL.value  != local::old_bsel;
                                           PDSEL.value != local::old_pdsel;
                                           SPSEL.value != local::old_spsel; });
    endfunction

    // task: write rg with its desired value, PSLVERR must be 1.
    virtual task write_locked(uvm_reg rg);
        uvm_status_e st;
        rg.write(st, rg.get(), .parent(this));
        if (st != UVM_NOT_OK)
            `uvm_error("PSLVERR_CHECK", $sformatf("%s write: PSLVERR=0, expected 1", rg.get_name()))
    endtask

    virtual task body();
        uvm_reg_data_t old_brg, old_mode;
        bit [2:0]      new_uen;

        `uvm_info(get_type_name, "Body entered...", UVM_LOW)

        // Power On Reset; Default Register, UART enabled
        init_rst(13, 10000);
        config_default();
        check_field(ral.MODE.UEN, 3'b111);

        // previous values
        read_reg(ral.BRG,  old_brg);
        read_reg(ral.MODE, old_mode);

       // new random values for BRG and MODE (BSEL, PDSEL, SPSEL)
        rand_new(); 
        cfg.check_pslverr = 0;                   
        write_locked(ral.BRG);
        write_locked(ral.MODE);
       
       //read back
        cfg.check_pslverr = 1;
        check_reg(ral.BRG,  old_brg); //already compare
        check_reg(ral.MODE, old_mode);

        // MODE with only UEN changed (PSTRB=4'b0001): PSLVERR=0, UEN updated
        // (non-zero and != 3'b111, so the value really changes)
        new_uen = 3'(1 + $urandom_range(5));
        uart_enable(new_uen);                           // reports an error if PSLVERR=1
        check_field(ral.MODE.UEN, new_uen);

        // UART disabled: the same writes are accepted (update_reg reports an error on PSLVERR=1)
        uart_disable();
        check_uen_disabled();
        rand_new();
        update_reg(ral.BRG);
        update_reg(ral.MODE);

        // UART enabled again: data_read = data_write
        uart_enable();
        check_field(ral.MODE.UEN, 3'b111);
        check_reg(ral.BRG,  ral.BRG.get());
        check_reg(ral.MODE, ral.MODE.get());

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass