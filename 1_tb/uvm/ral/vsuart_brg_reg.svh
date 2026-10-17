// Generated from the source DOCX by generate_model.py.
class vsuart_brg_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_brg_reg)
  rand uvm_reg_field BRG;
  uvm_reg_field RSVD_31_16;
  constraint legal_brg_c { BRG.value inside {[1:65535]}; }
  function new(string name="vsuart_brg_reg");
    super.new(name);
  endfunction
  virtual function void build();
    BRG       =make_vsuart_field("BRG", 16, 0, "RW", 32'h00000001, 0, 1);
    RSVD_31_16=make_vsuart_field("RSVD_31_16", 16, 16, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
