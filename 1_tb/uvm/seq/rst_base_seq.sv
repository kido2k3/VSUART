//===========================================================================
//-- Author         : kido
//-- Name           : rst_base_seq (reset base sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class rst_base_seq extends uvm_sequence #(rst_item);
    `uvm_object_utils(rst_base_seq)
    function new(string name = "rst_base_seq");
        super.new(name);
        req = rst_item::type_id::create("req");
    endfunction 

    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        start_item(req);
        finish_item(req);
        get_response(rsp);
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
