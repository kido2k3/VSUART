//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_rx_frame_formats_test
//-- History        : ver.1.00 (26/10/22) 1st release
//===========================================================================
class vsuart_rx_frame_formats_test extends base_test;
    `uvm_component_utils(vsuart_rx_frame_formats_test)

    function new(string name = "vsuart_rx_frame_formats_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);  
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_rx_frame_formats_seq::get_type());
        super.build_phase(phase);
        cfg.set_sys_freq(112);
    endfunction
endclass
