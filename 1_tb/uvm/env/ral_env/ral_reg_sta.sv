//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_sta (STA REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================


// Every status field is volatile: HW changes it without a bus access, so the
// mirror cannot predict it and mirror(UVM_CHECK) does not compare it.
class ral_reg_sta extends base_ral_reg;
  `uvm_object_utils(ral_reg_sta)

  uvm_reg_field TBSTA;              // [0]    RO
  uvm_reg_field TRSTA;              // [1]    RO
  uvm_reg_field TISTA;              // [2]    RO
  uvm_reg_field FRERR;              // [3]    RC, read clears
  uvm_reg_field PRERR;              // [4]    RC, read clears
  uvm_reg_field RISTA;              // [5]    RO
  uvm_reg_field RBOSTA;             // [6]    RC, read clears
  uvm_reg_field RBDSTA;             // [7]    RO
  uvm_reg_field RSVD_31_8;          // [31:8] RO, reserved

  // status seen by software reads (byte_en kept for the common signature)
  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    TBSTA:  coverpoint data[0] iff (is_read);
    TRSTA:  coverpoint data[1] iff (is_read);
    TISTA:  coverpoint data[2] iff (is_read);
    FRERR:  coverpoint data[3] iff (is_read);
    PRERR:  coverpoint data[4] iff (is_read);
    RISTA:  coverpoint data[5] iff (is_read);
    RBOSTA: coverpoint data[6] iff (is_read);
    RBDSTA: coverpoint data[7] iff (is_read);
  endgroup

  function new(string name="ral_reg_sta");
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
    TBSTA     = make_vsuart_field("TBSTA",       1,  0, "RO",  'h0, 1, 0);
    TRSTA     = make_vsuart_field("TRSTA",       1,  1, "RO",  'h0, 1, 0);
    TISTA     = make_vsuart_field("TISTA",       1,  2, "RO",  'h1, 1, 0);
    FRERR     = make_vsuart_field("FRERR",       1,  3, "RC",  'h0, 1, 0);
    PRERR     = make_vsuart_field("PRERR",       1,  4, "RC",  'h0, 1, 0);
    RISTA     = make_vsuart_field("RISTA",       1,  5, "RO",  'h1, 1, 0);
    RBOSTA    = make_vsuart_field("RBOSTA",      1,  6, "RC",  'h0, 1, 0);
    RBDSTA    = make_vsuart_field("RBDSTA",      1,  7, "RO",  'h0, 1, 0);
    RSVD_31_8 = make_vsuart_field("RSVD_31_8",  24,  8, "RO",  'h0, 0, 0);
  endfunction
endclass
