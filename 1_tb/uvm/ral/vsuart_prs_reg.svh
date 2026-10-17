// Generated from the source DOCX by generate_model.py.
class vsuart_prs_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_prs_reg)
  rand uvm_reg_field PRS;
  uvm_reg_field RSVD_31_4;
  function new(string name="vsuart_prs_reg");
    super.new(name);
  endfunction
  virtual function void build();
    PRS=make_vsuart_field("PRS", 4, 0, "RW", 32'h00000000, 0, 1);
    RSVD_31_4=make_vsuart_field("RSVD_31_4", 28, 4, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
