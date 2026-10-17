//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_ral_seq (register virtual sequence)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                : reset -> check reset values -> random config -> mirror check
//===========================================================================
class vsuart_ral_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_ral_seq)

    function new(string name = "vsuart_ral_seq");
        super.new(name);
    endfunction

    // task: frontdoor read every register and compare with the mirror
    virtual task ral_mirror_check();
        uvm_reg regs[$];
        uvm_status_e status;
        ral.get_registers(regs);
        foreach (regs[i]) begin
            regs[i].mirror(status, UVM_CHECK, UVM_FRONTDOOR, ral.default_map, this);
            if (status != UVM_IS_OK)
                `uvm_error("RAL", {"mirror failed: ", regs[i].get_name()})
        end
    endtask

    virtual task body();
        ral_config_seq cfg_seq;
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        if (ral == null || a_seqr == null)
            `uvm_fatal("RAL", "ral / a_seqr not connected")
        init_rst(13, 10000);

        // reset values (mirror is reset by vsuart_env on rst_n release)
        ral_mirror_check();

        // random configuration through ral
        cfg_seq = ral_config_seq::type_id::create("cfg_seq");
        cfg_seq.ral = ral;
        if (!cfg_seq.randomize()) `uvm_fatal("RAND", "ral_config_seq randomize failed")
        cfg_seq.start(a_seqr, this);
        ral_mirror_check();
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
