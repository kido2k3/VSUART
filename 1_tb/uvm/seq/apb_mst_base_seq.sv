//===========================================================================
//-- Author         : kido
//-- Name           : apb_mst_base_seq (apb master base sequence)
//-- History        : ver.1.00 (26/10/24) 1st release
//--                :
//===========================================================================
class apb_mst_base_seq extends uvm_sequence #(_apb_item);
    // sequence item for randomize
    rand _apb_item seq_item;

    `uvm_object_utils(apb_mst_base_seq)
    function new(string name = "apb_mst_base_seq");
        super.new(name);
        seq_item = _apb_item::type_id::create("seq_item");
    endfunction

    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        start_item(seq_item);
        `uvm_info("apb_mst_base_seq", $sformatf("\n%s", seq_item.sprint()), UVM_HIGH)
        finish_item(seq_item);
        get_response(rsp);
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
