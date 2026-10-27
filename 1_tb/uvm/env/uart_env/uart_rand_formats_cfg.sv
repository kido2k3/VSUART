//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_rand_formats_cfg (uart configuration to random different formats)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================
class uart_rand_formats_cfg extends uart_cfg;
    // for formats merge
    rand bit [3:0] merged_form;
    // queue of merged formats
    bit [3:0] merged_q[$];
    
    `uvm_object_utils_begin(uart_rand_formats_cfg)
    `uvm_object_utils_end

    constraint cstr_merged{
        merged_form == {data_width, parity_sel, stop_bit_sel};
        unique {merged_form, merged_q};
    }
    function new(string name = "uart_rand_formats_cfg");
        super.new(name);
    endfunction
    
    function void post_randomize;
        super.post_randomize;
        merged_q.push_back(merged_form);

        if(merged_q.size == 8) merged_q.delete;
    endfunction

endclass
