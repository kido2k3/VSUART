//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_reg_predictor (explicit predictor, _apb_item)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                : uvm_reg_predictor ignores the bus status, so a write the
//--                : DUT rejected (PSLVERR on protected MODE/BRG/PRS) or a
//--                : transfer aborted by reset would still update the mirror.
//--                : Drop those transfers before prediction.
//===========================================================================
class vsuart_reg_predictor extends uvm_reg_predictor #(_apb_item);
    `uvm_component_utils(vsuart_reg_predictor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void write(_apb_item tr);
        if (tr.status != UVM_TLM_OK_RESPONSE || tr.slverr) begin
            `uvm_info("RAL_PRED", $sformatf("skip prediction: addr=0x%0h %s slverr=%0b status=%s",
                      tr.addr, tr.trans_type.name(), tr.slverr, tr.status.name()), UVM_MEDIUM)
            return;
        end
        super.write(tr);
    endfunction
endclass
