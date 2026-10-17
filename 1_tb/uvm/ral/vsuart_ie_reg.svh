// Generated from the source DOCX by generate_model.py.
class vsuart_ie_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_ie_reg)
  rand uvm_reg_field TXTE;
  uvm_reg_field RSVD_7_1;
  rand uvm_reg_field RXTE;
  uvm_reg_field RSVD_15_9;
  rand uvm_reg_field ERRIE;
  uvm_reg_field RSVD_31_17;
  function new(string name="vsuart_ie_reg");
    super.new(name);
  endfunction
  virtual function void build();
    TXTE=make_vsuart_field("TXTE", 1, 0, "RW", 32'h00000000, 0, 1);
    RSVD_7_1=make_vsuart_field("RSVD_7_1", 7, 1, "RO", 32'h00000000, 0, 0);
    RXTE=make_vsuart_field("RXTE", 1, 8, "RW", 32'h00000000, 0, 1);
    RSVD_15_9=make_vsuart_field("RSVD_15_9", 7, 9, "RO", 32'h00000000, 0, 0);
    ERRIE=make_vsuart_field("ERRIE", 1, 16, "RW", 32'h00000000, 0, 1);
    RSVD_31_17=make_vsuart_field("RSVD_31_17", 15, 17, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
