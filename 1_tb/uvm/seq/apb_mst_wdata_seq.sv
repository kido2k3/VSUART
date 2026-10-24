//===========================================================================
//-- Author         : kido
//-- Name           : apb_mst_wdata_seq (apb master write data sequence)
//-- History        : ver.1.00 (26/10/24) 1st release
//--                :
//===========================================================================
class apb_mst_wdata_seq extends apb_mst_base_seq;
    `uvm_object_utils(apb_mst_wdata_seq)
    function new(string name = "apb_mst_wdata_seq");
        super.new(name);
    endfunction
    
    constraint data_cstr{
        seq_item.addr == 16'hFFFF;
        seq_item.trans_type == _apb_item::WRITE;
        seq_item.strb == 4'b0011;
    }

    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        super.body();
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
