//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_clear_ifs_seq (IFS W1C clear)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
class ral_clear_ifs_seq extends uvm_sequence #(_apb_item);
    `uvm_object_utils(ral_clear_ifs_seq)

    vsuart_reg_block ral;
    bit clear_tx = 0, clear_rx = 0, clear_err = 0;

    function new(string name = "ral_clear_ifs_seq");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;
        uvm_reg_data_t mask;
        if (ral == null) `uvm_fatal("RAL_SEQ", "Missing register model handle")
        mask = (uvm_reg_data_t'(clear_err) << 16) | (uvm_reg_data_t'(clear_rx) << 8) | clear_tx;
        // always issue the write: do not optimize away a W1C using a stale mirror
        ral.IFS.write(status, mask, UVM_FRONTDOOR, ral.default_map, this);
        if (status != UVM_IS_OK) `uvm_fatal("RAL_IFS", "IFS clear failed")
    endtask
endclass
