//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_ie (IE REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

class ral_reg_ie extends base_ral_reg;
  `uvm_object_utils(ral_reg_ie)

  rand uvm_reg_field TXTE;          // [0]     RW
  uvm_reg_field RSVD_7_1;           // [7:1]   RO, reserved
  rand uvm_reg_field RXTE;          // [8]     RW
  uvm_reg_field RSVD_15_9;          // [15:9]  RO, reserved
  rand uvm_reg_field ERRIE;         // [16]    RW
  uvm_reg_field RSVD_31_17;         // [31:17] RO, reserved

  // a field counts only if its byte lane was driven (reads: all lanes)
  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    TXTE:  coverpoint data[0]  iff (byte_en[0]);
    RXTE:  coverpoint data[8]  iff (byte_en[1]);
    ERRIE: coverpoint data[16] iff (byte_en[2]);
    DIR:   coverpoint is_read;
  endgroup

  function new(string name="ral_reg_ie");
    super.new(name);
    if (has_coverage(UVM_CVR_FIELD_VALS)) cg_vals = new();
  endfunction

  // called by the predictor for every observed access, before the mirror update
  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                         bit is_read, uvm_reg_map map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) cg_vals.sample(data, byte_en, is_read);
  endfunction

  virtual function void build();
    TXTE       = make_vsuart_field("TXTE",         1,  0, "RW",  'h0, 0, 1);
    RSVD_7_1   = make_vsuart_field("RSVD_7_1",     7,  1, "RO",  'h0, 0, 0);
    RXTE       = make_vsuart_field("RXTE",         1,  8, "RW",  'h0, 0, 1);
    RSVD_15_9  = make_vsuart_field("RSVD_15_9",    7,  9, "RO",  'h0, 0, 0);
    ERRIE      = make_vsuart_field("ERRIE",        1, 16, "RW",  'h0, 0, 1);
    RSVD_31_17 = make_vsuart_field("RSVD_31_17",  15, 17, "RO",  'h0, 0, 0);
  endfunction
endclass
