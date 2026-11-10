//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_reset_value_test
//-- Description    : Test-plan scenario 1: global reset values and output pins
//-- History        : ver.1.00 (26/11/06) Test-plan implementation
//===========================================================================

class vsuart_reset_value_test extends base_test;
    `uvm_component_utils(vsuart_reset_value_test)

    function new(string name = "vsuart_reset_value_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_reset_value_seq::get_type());
        super.build_phase(phase);
        cfg.set_sys_freq(112);
    endfunction
endclass
