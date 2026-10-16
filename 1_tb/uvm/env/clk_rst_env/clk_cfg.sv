//===========================================================================
//-- Author         : kido
//-- Name           : clk_cfg (clk configuration)
//-- History        : ver.1.00 (26/10/14) 1st release
//--                :
//===========================================================================

class clk_cfg extends uvm_object;
    
    int _sys_freq = 112;
    string sys_freq = "112MHz";
    int _apb_freq = 72;
    string apb_freq = "72MHz";
    const int _uart_freq = 12;
    const string uart_freq = "12MHz";

    `uvm_object_utils_begin(clk_cfg)
        `uvm_field_string(sys_freq, UVM_ALL_ON)
        `uvm_field_int(_sys_freq, UVM_ALL_ON | UVM_NOPRINT)
        `uvm_field_string(apb_freq, UVM_ALL_ON)
        `uvm_field_int(_apb_freq, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_object_utils_end
    
    function new(string name = "clk_cfg");
        super.new(name);
    endfunction
    
    // print extra constant attributes
    virtual function void do_print(uvm_printer printer);
        printer.print_string("uart_freq", uart_freq);
    endfunction

    // function get string for freq value
    function void get_string (ref string freq, int _freq);
        freq = $sformatf("%0dMHz", _freq);
    endfunction
    // function: set system frequency
    function void set_sys_freq(int freq);
        if(freq inside {112, 200}) begin
            _sys_freq = freq;
            get_string(sys_freq, _sys_freq);
        end else begin
            `uvm_fatal("INVALID_FREQ", $sformatf("system frequency %0dMHz is not supported", freq))
        end
    endfunction
    
    // function: set apb frequency
    function void set_apb_freq(int freq);
        if(freq inside {72}) begin
            _apb_freq = freq;
            get_string(apb_freq, _apb_freq);
        end else begin
            `uvm_fatal("INVALID_FREQ", $sformatf("APB frequency %0dMHz is not supported", freq))
        end
    endfunction
endclass


