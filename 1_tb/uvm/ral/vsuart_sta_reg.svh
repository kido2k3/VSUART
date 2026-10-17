// Generated from the source DOCX by generate_model.py.
class vsuart_sta_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_sta_reg)
  uvm_reg_field TBSTA;
  uvm_reg_field TRSTA;
  uvm_reg_field TISTA;
  uvm_reg_field FRERR;
  uvm_reg_field PRERR;
  uvm_reg_field RISTA;
  uvm_reg_field RBOSTA;
  uvm_reg_field RBDSTA;
  uvm_reg_field RSVD_31_8;
  function new(string name="vsuart_sta_reg");
    super.new(name);
  endfunction
  virtual function void build();
    TBSTA=make_vsuart_field("TBSTA", 1, 0, "RO", 32'h00000000, 1, 0);
    TRSTA=make_vsuart_field("TRSTA", 1, 1, "RO", 32'h00000000, 1, 0);
    TISTA=make_vsuart_field("TISTA", 1, 2, "RO", 32'h00000001, 1, 0);
    FRERR=make_vsuart_field("FRERR", 1, 3, "RC", 32'h00000000, 1, 0);
    PRERR=make_vsuart_field("PRERR", 1, 4, "RC", 32'h00000000, 1, 0);
    RISTA=make_vsuart_field("RISTA", 1, 5, "RO", 32'h00000001, 1, 0);
    RBOSTA=make_vsuart_field("RBOSTA", 1, 6, "RC", 32'h00000000, 1, 0);
    RBDSTA=make_vsuart_field("RBDSTA", 1, 7, "RO", 32'h00000000, 1, 0);
    RSVD_31_8=make_vsuart_field("RSVD_31_8", 24, 8, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
