//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_tx_enable_disable_test
//-- Description    : clearing UEN[0] aborts TX and clears TX FIFO (F2.4.2.4)
//-- History        : ver.1.00 (26/11/17) 1st release
//===========================================================================
class vsuart_tx_enable_disable_test extends base_test;
    `uvm_component_utils(vsuart_tx_enable_disable_test)

    function new(string name = "vsuart_tx_enable_disable_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_tx_enable_disable_seq::get_type());
        super.build_phase(phase);
        cfg.set_sys_freq(112);
        cfg.u_cfg.check_bittime = 0;
    endfunction
endclass
