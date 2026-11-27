//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_clock_cdc_140m_100m_test
//-- Description    : vsuart_clock_cdc_base_test at sys_clk 140 MHz / PCLK 100 MHz (maximum sys_clk, maximum PCLK)
//-- History        : ver.1.00 (26/11/25) 1st release
//===========================================================================
class vsuart_clock_cdc_140m_100m_test extends vsuart_clock_cdc_base_test;
    `uvm_component_utils(vsuart_clock_cdc_140m_100m_test)

    function new(string name = "vsuart_clock_cdc_140m_100m_test", uvm_component parent = null);
        super.new(name, parent);
        sys_mhz  = 140;
        pclk_mhz = 100;
    endfunction
endclass
