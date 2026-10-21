//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_prs (PRS REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

class ral_reg_prs extends base_ral_reg;
  `uvm_object_utils(ral_reg_prs)

  rand uvm_reg_field PRS;           // [3:0]  RW, protected (UEN[2] = 0)
  uvm_reg_field RSVD_31_4;          // [31:4] RO, reserved

  // a field counts only if its byte lane was driven (reads: all lanes)
  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    PRS: coverpoint data[3:0] iff (byte_en[0]);
    DIR: coverpoint is_read;
  endgroup

  function new(string name="ral_reg_prs");
    super.new(name);
    if (has_coverage(UVM_CVR_FIELD_VALS)) cg_vals = new();
  endfunction

  // called by the predictor for every observed access, before the mirror update
  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                         bit is_read, uvm_reg_map map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) cg_vals.sample(data, byte_en, is_read);
  endfunction

  virtual function void build();
    // make_vsuart_field: name, width, lsb, access, reset, volatile, rand[, indv]
    PRS       = make_vsuart_field("PRS",         4,  0, "RW",  'h0, 0, 1);
    RSVD_31_4 = make_vsuart_field("RSVD_31_4",  28,  4, "RO",  'h0, 0, 0);
  endfunction
endclass
