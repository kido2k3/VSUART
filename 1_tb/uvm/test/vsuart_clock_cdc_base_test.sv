//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_clock_cdc_base_test
//-- Description    : TX/RX transfer across PCLK and sys_clk domains, sys_clk 112 MHz / PCLK 72 MHz
//-- History        : ver.1.00 (26/11/25) 1st release
//===========================================================================
class vsuart_clock_cdc_base_test extends base_test;
    `uvm_component_utils(vsuart_clock_cdc_base_test)

    int sys_mhz  = 112;
    int pclk_mhz = 72;

    function new(string name = "vsuart_clock_cdc_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_full_duplex_seq::get_type());
        super.build_phase(phase);
        cfg.enable_continous = 1;
        cfg.set_sys_freq(sys_mhz);
        cfg.set_apb_freq(pclk_mhz);
    endfunction
endclass
