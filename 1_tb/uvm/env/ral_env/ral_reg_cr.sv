//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_cr (CR REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

class ral_reg_cr extends base_ral_reg;
  `uvm_object_utils(ral_reg_cr)

  rand uvm_reg_field TXISEL;        // [1:0]   RW
  uvm_reg_field RSVD_7_2;           // [7:2]   RO, reserved
  rand uvm_reg_field RXISEL;        // [9:8]   RW
  uvm_reg_field RSVD_31_10;         // [31:10] RO, reserved

  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    TXISEL: coverpoint data[1:0] iff (byte_en[0]);
    RXISEL: coverpoint data[9:8] iff (byte_en[1]);
    DIR:    coverpoint is_read;
  endgroup

  function new(string name="ral_reg_cr");
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
    TXISEL     = make_vsuart_field("TXISEL",       2,  0, "RW",  'h0, 0, 1);
    RSVD_7_2   = make_vsuart_field("RSVD_7_2",     6,  2, "RO",  'h0, 0, 0);
    RXISEL     = make_vsuart_field("RXISEL",       2,  8, "RW",  'h0, 0, 1);
    RSVD_31_10 = make_vsuart_field("RSVD_31_10",  22, 10, "RO",  'h0, 0, 0);
  endfunction
endclass
