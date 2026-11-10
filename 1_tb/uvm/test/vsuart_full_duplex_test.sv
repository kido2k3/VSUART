//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_full_duplex_test
//-- History        : ver.1.00 (4/11/22) 1st release
//===========================================================================
class vsuart_full_duplex_test extends base_test;
  `uvm_component_utils(vsuart_full_duplex_test)

  function new(string name = "vsuart_full_duplex_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_full_duplex_seq::get_type());
    super.build_phase(phase);
    cfg.enable_continous = 1;
    cfg.set_sys_freq(112);
  endfunction
endclass
