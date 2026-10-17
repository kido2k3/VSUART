// Generated from the source DOCX by generate_model.py.
class vsuart_ifs_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_ifs_reg)
  uvm_reg_field TXIFS;
  uvm_reg_field RSVD_7_1;
  uvm_reg_field RXIFS;
  uvm_reg_field RSVD_15_9;
  uvm_reg_field ERRIFS;
  uvm_reg_field RSVD_31_17;
  function new(string name="vsuart_ifs_reg");
    super.new(name);
  endfunction
  virtual function void build();
    TXIFS=make_vsuart_field("TXIFS", 1, 0, "W1C", 32'h00000000, 1, 0);
    RSVD_7_1=make_vsuart_field("RSVD_7_1", 7, 1, "RO", 32'h00000000, 0, 0);
    RXIFS=make_vsuart_field("RXIFS", 1, 8, "W1C", 32'h00000000, 1, 0);
    RSVD_15_9=make_vsuart_field("RSVD_15_9", 7, 9, "RO", 32'h00000000, 0, 0);
    ERRIFS=make_vsuart_field("ERRIFS", 1, 16, "W1C", 32'h00000000, 1, 0);
    RSVD_31_17=make_vsuart_field("RSVD_31_17", 15, 17, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
