//===========================================================================
//-- Author         : nddm
//-- Name           : apb_mst_wdata_burst_seq 
//-- History        : ver.1.00 (26/10/24) 1st release
//===========================================================================

class apb_mst_wdata_burst_seq extends uvm_sequence #(_apb_item);
    `uvm_object_utils(apb_mst_wdata_burst_seq)

    // Dynamic array allows any burst length (16, 128, etc.) set by the caller
    bit [8:0] payload[];

    function new(string name = "apb_mst_wdata_burst_seq");
        super.new(name);
    endfunction

    virtual task body();
        if (payload.size() == 0)
            `uvm_fatal("TX_FIFO_EMPTY", "Burst payload array is empty")

        // Dynamically expand UVM response queue depth
        set_response_queue_depth(payload.size());

        // Phase 1: Issue back-to-back WRITE requests without blocking on responses
        foreach (payload[i]) begin
            _apb_item req = _apb_item::type_id::create($sformatf("fifo_%0d", i));
            start_item(req);
            
            // Equivalent to apb_mst_wdata_seq::data_cstr, with deterministic payload
            req.addr       = 16'hffff;
            req.data       = {23'b0, payload[i]};
            req.strb       = 4'b0011;
            req.trans_type = _apb_item::WRITE;
            req.set_transaction_id(i);
            
            // Unblocks as soon as driver accepts the item in ACCESS phase.
            finish_item(req);
        end

        // Phase 2: Collect all responses after the entire burst is dispatched
        foreach (payload[i]) begin
            get_response(rsp, i);
            if (rsp.status != UVM_TLM_OK_RESPONSE || rsp.slverr)
                `uvm_fatal("TX_FIFO_WRITE", $sformatf("FIFO write %0d failed", i))
        end
    endtask
endclass