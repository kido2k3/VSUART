class vsuart_irq_w1c_clear_test extends base_test;
    `uvm_component_utils(vsuart_irq_w1c_clear_test)

    function new(string name = "vsuart_irq_w1c_clear_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_irq_w1c_clear_seq::get_type());
        super.build_phase(phase);
        cfg.check_interrupt_pending = 1;
        cfg.check_parity_error = 0;
        cfg.check_frame_error= 0;
        // config_default at 112 MHz: BSEL=1, BRG=2916 -> 9600 bps (spec table 3-7).
        cfg.set_sys_freq(112);
    endfunction

endclass
