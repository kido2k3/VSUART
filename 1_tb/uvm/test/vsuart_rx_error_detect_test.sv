class vsuart_rx_error_detect_test extends base_test;
  `uvm_component_utils(vsuart_rx_error_detect_test)

  function new(string name = "vsuart_rx_error_detect_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_rx_error_detect_seq::get_type());
    super.build_phase(phase);
    cfg.enable_continous = 1;
    cfg.check_parity_error = 0;
    cfg.check_frame_error = 0;
    cfg.set_sys_freq(112);
  endfunction
endclass
