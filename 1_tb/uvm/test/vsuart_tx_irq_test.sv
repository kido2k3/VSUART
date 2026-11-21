//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_tx_irq_test
//-- Description    : TX interrupt for TXISEL = 00, 10, 01 (F2.4.4.1-3)
//-- History        : ver.1.00 (26/11/17) 1st release
//===========================================================================
class vsuart_tx_irq_test extends base_test;
    `uvm_component_utils(vsuart_tx_irq_test)

    function new(string name = "vsuart_tx_irq_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_tx_irq_seq::get_type());
        super.build_phase(phase);
        cfg.set_sys_freq(112);
        // every TXIFS is cleared by the sequence
        cfg.check_interrupt_pending = 1;
    endfunction
endclass
