//===========================================================================
//-- Author         : manhndd
//-- Name           : irq_agt (single-line interrupt agent)
//-- History        : ver.1.00 (26/11/07) Single-line reusable IRQ agent
//===========================================================================
class irq_agt extends uvm_agent;
    `uvm_component_utils(irq_agt)

    irq_mon mon;
    uvm_analysis_port #(irq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = irq_mon::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap = mon.ap;
    endfunction

    // Query methods
    function bit get_level();  return mon.get_level();  endfunction
    function bit is_pending(); return mon.is_pending(); endfunction
endclass

