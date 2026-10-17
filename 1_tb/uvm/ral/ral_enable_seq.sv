//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_enable_seq (MODE.UEN write)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                : direct APB low-byte write (PSTRB=0001) to change UEN
//--                : without touching protected MODE lanes. A ral MODE.write()
//--                : drives PSTRB=1111 and is rejected while the UART is enabled
//===========================================================================
class ral_enable_seq extends uvm_sequence #(_apb_item);
    `uvm_object_utils(ral_enable_seq)

    vsuart_reg_block ral;
    rand bit [2:0] uen = 0;

    function new(string name = "ral_enable_seq");
        super.new(name);
    endfunction

    virtual task body();
        _apb_item request;
        if (ral == null) `uvm_fatal("RAL_SEQ", "Missing register model handle")
        request = _apb_item::type_id::create("enable_request");
        start_item(request);
        request.addr       = ral.MODE.get_address(ral.default_map);
        request.trans_type = _apb_item::WRITE;
        request.data       = {29'b0, uen};
        request.strb       = 4'b0001;
        finish_item(request);
        get_response(rsp); // apb_mst_drv returns the response with put()
        if (rsp.status != UVM_TLM_OK_RESPONSE || rsp.slverr)
            `uvm_fatal("RAL_ENABLE", rsp.sprint())
    endtask
endclass
