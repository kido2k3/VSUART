// Generated from the source DOCX by generate_model.py.
class vsuart_cr_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_cr_reg)
  rand uvm_reg_field TXISEL;
  uvm_reg_field RSVD_7_2;
  rand uvm_reg_field RXISEL;
  uvm_reg_field RSVD_31_10;
  function new(string name="vsuart_cr_reg");
    super.new(name);
  endfunction
  virtual function void build();
    TXISEL=make_vsuart_field("TXISEL", 2, 0, "RW", 32'h00000000, 0, 1);
    RSVD_7_2=make_vsuart_field("RSVD_7_2", 6, 2, "RO", 32'h00000000, 0, 0);
    RXISEL=make_vsuart_field("RXISEL", 2, 8, "RW", 32'h00000000, 0, 1);
    RSVD_31_10=make_vsuart_field("RSVD_31_10", 22, 10, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
