//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_clock_cdc_40m_39m_test
//-- Description    : vsuart_clock_cdc_base_test at sys_clk 40 MHz / PCLK 39 MHz (minimum sys_clk, PCLK just below sys_clk)
//-- History        : ver.1.00 (26/11/25) 1st release
//===========================================================================
class vsuart_clock_cdc_40m_39m_test extends vsuart_clock_cdc_base_test;
    `uvm_component_utils(vsuart_clock_cdc_40m_39m_test)

    function new(string name = "vsuart_clock_cdc_40m_39m_test", uvm_component parent = null);
        super.new(name, parent);
        sys_mhz  = 40;
        pclk_mhz = 39;
    endfunction
endclass
