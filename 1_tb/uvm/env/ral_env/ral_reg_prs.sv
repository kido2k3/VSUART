//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_prs (PRS REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                  ver.1.01 (26/11/11) prescaler removed:
//===========================================================================

class ral_reg_prs extends base_ral_reg;
  `uvm_object_utils(ral_reg_prs)

  uvm_reg_field RSVD_31_0;          // [31:0] RO, reserved (internal use)

  function new(string name="ral_reg_prs");
    super.new(name);
  endfunction

  virtual function void build();
    // make_vsuart_field: name, width, lsb, access, reset, volatile, rand[, indv]
    RSVD_31_0 = make_vsuart_field("RSVD_31_0",  32,  0, "RO",  'h0, 0, 0);
  endfunction
endclass
