//===========================================================================
//-- Author         : trizrd
//-- Name           : apb_mst_rd_chk_seq 
//-- History        : ver.1.00 (26/10/24) 1st release
//===========================================================================

class apb_mst_rd_chk_seq extends uvm_sequence #(_apb_item);
    `uvm_object_utils(apb_mst_rd_chk_seq)

    bit [31:0] rdata;   
    bit        slverr;  

    function new(string name = "apb_mst_rd_chk_seq");
        super.new(name);
    endfunction

    virtual task body();
       _apb_item req = _apb_item::type_id::create("rx_fifo_rd");
        start_item(req);
        req.addr       = 16'hffff;          // RX FIFO
        req.trans_type = _apb_item::READ;
        finish_item(req);
        get_response(rsp);
        rdata  = rsp.data;
        slverr = rsp.slverr;

    endtask
endclass