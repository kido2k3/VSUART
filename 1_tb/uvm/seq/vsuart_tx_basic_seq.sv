//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_tx_basic_seq (virtual sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//===========================================================================

class vsuart_tx_basic_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_basic_seq)

    rand bit [8:0] payload[16];

    function new(string name = "vsuart_tx_basic_seq");
        super.new(name);
    endfunction


    virtual task body();
        apb_mst_wdata_burst_seq burst;
        if (ral == null || cfg == null)
            `uvm_fatal("TX_SETUP", "Missing RAL/configuration")
        if (!std::randomize(payload))
            `uvm_fatal("TX_RANDOM", "Payload randomization failed")

        init_rst(13, 10000);
        config_default();
        cfg.enable_continous = 1;

        burst = apb_mst_wdata_burst_seq::type_id::create("burst");
        burst.payload = payload;
        `uvm_info("TX_BASIC_DATA", $sformatf("FIFO payloads: %p", payload), UVM_LOW)
        burst.start(a_seqr, this);
        `uvm_info("TX_BASIC_SENT", "Sent 16 TX FIFO writes; checking is handled by monitor/scoreboard", UVM_LOW)
    endtask
endclass
