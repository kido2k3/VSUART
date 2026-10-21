//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_brg (BRG REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

class ral_reg_brg extends base_ral_reg;
  `uvm_object_utils(ral_reg_brg)

  rand uvm_reg_field BRG;           // [15:0]  RW, protected
  uvm_reg_field RSVD_31_16;         // [31:16] RO, reserved

  constraint legal_brg_c { BRG.value inside {[1:65535]}; } // BRG = 0 illegal

  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    BRG: coverpoint data[15:0] iff (&byte_en[1:0]) {
      bins min  = {1};
      bins mid  = {[2:65534]};
      bins max  = {65535};
    }
    DIR: coverpoint is_read;
  endgroup

  function new(string name="ral_reg_brg");
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
    BRG        = make_vsuart_field("BRG",         16,  0, "RW",  'h1, 0, 1);
    RSVD_31_16 = make_vsuart_field("RSVD_31_16",  16, 16, "RO",  'h0, 0, 0);
  endfunction
endclass
