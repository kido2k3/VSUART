//===========================================================================
//-- Author         : kido
//-- Name           : rst_item (reset item)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class rst_item extends uvm_sequence_item;

    typedef enum {CLK_PENDING, NO_CLK_PENDING} type_e;
    
    type_e rst_type;
    int interval_time;
    int rst_time;

    `uvm_object_utils_begin(rst_item)
        `uvm_field_enum(type_e, rst_type, UVM_ALL_ON)
        `uvm_field_int(interval_time, UVM_ALL_ON)
        `uvm_field_int(rst_time, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "rst_item");
        super.new(name);
        interval_time = 2;
        rst_time = 500;
        rst_type = CLK_PENDING;
    endfunction

endclass
