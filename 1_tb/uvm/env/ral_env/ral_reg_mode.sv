//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_mode (MODE REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

class ral_reg_mode extends base_ral_reg;
  `uvm_object_utils(ral_reg_mode)

  uvm_reg_field UEN;           // [2:0]   RW, written alone (PSTRB=0001)
  uvm_reg_field RSVD_7_3;           // [7:3]   RO, reserved
  rand uvm_reg_field BSEL;          // [8]     RW, protected
  uvm_reg_field RSVD_15_9;          // [15:9]  RO, reserved
  rand uvm_reg_field PDSEL;         // [17:16] RW, protected
  uvm_reg_field RSVD_23_18;         // [23:18] RO, reserved
  rand uvm_reg_field SPSEL;         // [24]    RW, protected
  uvm_reg_field RSVD_31_25;         // [31:25] RO, reserved

  // a field counts only if its byte lane was driven (reads: all lanes);
  // a UEN-only write carries zero values in the other lanes
  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    UEN:   coverpoint data[2:0]   iff (byte_en[0]);
    BSEL:  coverpoint data[8]     iff (byte_en[1]);
    PDSEL: coverpoint data[17:16] iff (byte_en[2]);
    SPSEL: coverpoint data[24]    iff (byte_en[3]);
    DIR:   coverpoint is_read;
  endgroup

  function new(string name="ral_reg_mode");
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
    UEN        = make_vsuart_field("UEN",          3,  0, "RW",  'h0, 0, 1, 1);
    RSVD_7_3   = make_vsuart_field("RSVD_7_3",     5,  3, "RO",  'h0, 0, 0);
    BSEL       = make_vsuart_field("BSEL",         1,  8, "RW",  'h0, 0, 1);
    RSVD_15_9  = make_vsuart_field("RSVD_15_9",    7,  9, "RO",  'h0, 0, 0);
    PDSEL      = make_vsuart_field("PDSEL",        2, 16, "RW",  'h1, 0, 1);
    RSVD_23_18 = make_vsuart_field("RSVD_23_18",   6, 18, "RO",  'h0, 0, 0);
    SPSEL      = make_vsuart_field("SPSEL",        1, 24, "RW",  'h0, 0, 1);
    RSVD_31_25 = make_vsuart_field("RSVD_31_25",   7, 25, "RO",  'h0, 0, 0);
  endfunction
endclass
