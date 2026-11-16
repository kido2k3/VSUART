//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_brg_boundary_test
//-- Description    : F2.3.2.x baud rate at BRG = 1 / 65535 / 0, sys_clk 112 MHz
//-- History        : ver.1.00 (26/11/13) 1st release
//--                : ver.1.01 (26/11/14) frames counted through sva_vif
//===========================================================================
class vsuart_brg_boundary_test extends base_test;
    `uvm_component_utils(vsuart_brg_boundary_test)



    function new(string name = "vsuart_brg_boundary_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_brg_boundary_seq::get_type());
        super.build_phase(phase);
        uvm_top.set_timeout(150ms, 1);
        cfg.set_sys_freq(112);
    endfunction

endclass
