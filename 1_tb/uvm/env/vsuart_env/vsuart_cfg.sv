//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_cfg (vsuart configuration)
//-- History        : ver.1.00 (26/10/14) 1st release
//--                :
//===========================================================================

class vsuart_cfg extends uvm_object;
    
    clk_cfg c_cfg;
    uart_cfg uart_cfg;

    `uvm_object_utils_begin(vsuart_cfg)
        `uvm_field_object(c_cfg, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "vsuart_cfg");
        super.new(name);
        c_cfg = clk_cfg::type_id::create("c_cfg");
        uart_cfg = uart_cfg::type_id::create("uart_cfg");
    endfunction
    
    // function: set system frequency
    function void set_sys_freq(int freq);
        c_cfg.set_sys_freq(freq);
    endfunction

    // function: set apb frequency
    function void set_apb_freq(int freq);
        c_cfg.set_apb_freq(freq);
    endfunction
endclass

