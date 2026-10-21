//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_reg_ifs (IFS REG)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
// Interrupt flags: set by HW (volatile), cleared by software W1C
class ral_reg_ifs extends base_ral_reg;
  `uvm_object_utils(ral_reg_ifs)

  uvm_reg_field TXIFS;              // [0]     W1C
  uvm_reg_field RSVD_7_1;           // [7:1]   RO, reserved
  uvm_reg_field RXIFS;              // [8]     W1C
  uvm_reg_field RSVD_15_9;          // [15:9]  RO, reserved
  uvm_reg_field ERRIFS;             // [16]    W1C
  uvm_reg_field RSVD_31_17;         // [31:17] RO, reserved


  covergroup cg_vals with function sample(uvm_reg_data_t data, uvm_reg_data_t byte_en,
                                          bit is_read);
    option.per_instance = 1;
    TXIFS:  coverpoint data[0]  iff (byte_en[0]);
    RXIFS:  coverpoint data[8]  iff (byte_en[1]);
    ERRIFS: coverpoint data[16] iff (byte_en[2]);
    DIR:    coverpoint is_read;
    TX_X:   cross TXIFS, DIR;
    RX_X:   cross RXIFS, DIR;
    ERR_X:  cross ERRIFS, DIR;
  endgroup

  function new(string name="ral_reg_ifs");
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
    TXIFS      = make_vsuart_field("TXIFS",        1,  0, "W1C", 'h0, 1, 0);
    RSVD_7_1   = make_vsuart_field("RSVD_7_1",     7,  1, "RO",  'h0, 0, 0);
    RXIFS      = make_vsuart_field("RXIFS",        1,  8, "W1C", 'h0, 1, 0);
    RSVD_15_9  = make_vsuart_field("RSVD_15_9",    7,  9, "RO",  'h0, 0, 0);
    ERRIFS     = make_vsuart_field("ERRIFS",       1, 16, "W1C", 'h0, 1, 0);
    RSVD_31_17 = make_vsuart_field("RSVD_31_17",  15, 17, "RO",  'h0, 0, 0);
  endfunction
endclass
