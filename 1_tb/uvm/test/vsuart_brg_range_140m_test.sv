//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_brg_range_140m_test
//-- Description    : vsuart_brg_range_test at sys_clk 140 MHz
//-- History        : ver.1.00 (26/11/13) 1st release (200 MHz)
//--                : ver.1.01 (26/11/14) 200 MHz -> 140 MHz
//===========================================================================
class vsuart_brg_range_140m_test extends vsuart_brg_range_test;
    `uvm_component_utils(vsuart_brg_range_140m_test)

    function new(string name = "vsuart_brg_range_140m_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_top.set_timeout(60ms, 1);
        cfg.set_sys_freq(140);
    endfunction
endclass
