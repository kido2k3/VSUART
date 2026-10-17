// Generated from the source DOCX by generate_model.py.
class vsuart_mode_reg extends vsuart_reg_base;
  `uvm_object_utils(vsuart_mode_reg)
  rand uvm_reg_field UEN;
  uvm_reg_field RSVD_7_3;
  rand uvm_reg_field BSEL;
  uvm_reg_field RSVD_15_9;
  rand uvm_reg_field PDSEL;
  uvm_reg_field RSVD_23_18;
  rand uvm_reg_field SPSEL;
  uvm_reg_field RSVD_31_25;
  function new(string name="vsuart_mode_reg");
    super.new(name);
  endfunction
  virtual function void build();
    UEN=make_vsuart_field("UEN", 3, 0, "RW", 32'h00000000, 0, 1);
    RSVD_7_3=make_vsuart_field("RSVD_7_3", 5, 3, "RO", 32'h00000000, 0, 0);
    BSEL=make_vsuart_field("BSEL", 1, 8, "RW", 32'h00000000, 0, 1);
    RSVD_15_9=make_vsuart_field("RSVD_15_9", 7, 9, "RO", 32'h00000000, 0, 0);
    PDSEL=make_vsuart_field("PDSEL", 2, 16, "RW", 32'h00000001, 0, 1);
    RSVD_23_18=make_vsuart_field("RSVD_23_18", 6, 18, "RO", 32'h00000000, 0, 0);
    SPSEL=make_vsuart_field("SPSEL", 1, 24, "RW", 32'h00000000, 0, 1);
    RSVD_31_25=make_vsuart_field("RSVD_31_25", 7, 25, "RO", 32'h00000000, 0, 0);
  endfunction
endclass
