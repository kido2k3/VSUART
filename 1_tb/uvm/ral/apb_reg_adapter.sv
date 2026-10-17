//===========================================================================
//-- Author         : manhndd
//-- Name           : apb_reg_adapter (uvm_reg <-> _apb_item)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                : apb_mst_drv returns the response with put(),
//--                : so provides_responses = 1
//===========================================================================
class apb_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(apb_reg_adapter)

    function new(string name = "apb_reg_adapter");
        super.new(name);
        provides_responses = 1;
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        _apb_item pkt = _apb_item::type_id::create("pkt");
        pkt.trans_type = (rw.kind == UVM_WRITE) ? _apb_item::WRITE : _apb_item::READ;
        pkt.addr = rw.addr;
        pkt.data = rw.data;
        // apb_mst_drv drives PSTRB from the item: register writes are full-word
        pkt.strb = (rw.kind == UVM_WRITE) ? '1 : 0;
        `uvm_info("adapter", $sformatf("reg2bus addr=0x%0h data=0x%0h kind=%s", pkt.addr, pkt.data, rw.kind.name()), UVM_DEBUG)
        return pkt;
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        _apb_item pkt;
        if (!$cast(pkt, bus_item))
            `uvm_fatal("adapter", "Failed to cast bus_item to _apb_item")
        rw.kind = (pkt.trans_type == _apb_item::WRITE) ? UVM_WRITE : UVM_READ;
        rw.addr = pkt.addr;
        rw.data = pkt.data;
        // forward PSTRB, otherwise the predictor treats every observed write
        // (e.g. ral_enable_seq, PSTRB=0001) as a full-word write
        rw.byte_en = (rw.kind == UVM_WRITE) ? pkt.strb : '1;
        // report SLVERR and reset-aborted transfers to the frontdoor caller
        rw.status = (pkt.status == UVM_TLM_OK_RESPONSE && !pkt.slverr) ? UVM_IS_OK : UVM_NOT_OK;
        `uvm_info("adapter", $sformatf("bus2reg addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_DEBUG)
    endfunction
endclass
