//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_apb_reset_test
//-- Description    : Test-plan scenario 2: APB reset recovery
//-- History        : ver.1.00 (26/11/06) Test-plan implementation
//===========================================================================

class vsuart_apb_reset_test extends base_test;
    `uvm_component_utils(vsuart_apb_reset_test)

    function new(string name = "vsuart_apb_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_apb_reset_seq::get_type());
        super.build_phase(phase);
        cfg.set_sys_freq(112);
    endfunction
endclass
