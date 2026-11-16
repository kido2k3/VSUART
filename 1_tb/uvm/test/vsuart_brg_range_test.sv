//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_brg_range_test
//-- Description    : F2.3.1.x TX baud rate at the standard rates, sys_clk 112 MHz (table 3-7)
//-- History        : ver.1.00 (26/11/13) 1st release
//--                : ver.1.01 (26/11/14) baud checked by A_TX_BAUD through sva_vif
//===========================================================================
class vsuart_brg_range_test extends base_test;
    `uvm_component_utils(vsuart_brg_range_test)


    function new(string name = "vsuart_brg_range_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_brg_range_seq::get_type());
        super.build_phase(phase);
        uvm_top.set_timeout(60ms, 1);
        cfg.set_sys_freq(112);
    endfunction

endclass
