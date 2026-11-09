//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_env (interrupt environment with 3 agents)
//-- History        : ver.1.00 (26/11/07) 3-agent interrupt environment
//===========================================================================
class ifs_env extends uvm_env;
    `uvm_component_utils(ifs_env)

    virtual ifs_if vif;

    // 3 agent -> 3 interrupt
    irq_agt tx_agt;
    irq_agt rx_agt;
    irq_agt err_agt;

    // Analysis port broadcasting items from all 3 agents
    uvm_analysis_port #(irq_item) ap;
    uvm_analysis_imp  #(irq_item, ifs_env) fwd_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap      = new("ap", this);
        fwd_imp = new("fwd_imp", this);

        if (!uvm_config_db#(virtual ifs_if)::get(this, "", "ifs_vif", vif)) begin
            `uvm_fatal("NOT_IF", "ifs_vif not found in ifs_env")
        end

        // Pass single-wire sub-interfaces to each individual agent
        uvm_config_db#(virtual irq_if)::set(this, "tx_agt*",  "vif", vif.tx_if);
        uvm_config_db#(virtual irq_if)::set(this, "rx_agt*",  "vif", vif.rx_if);
        uvm_config_db#(virtual irq_if)::set(this, "err_agt*", "vif", vif.err_if);

        // Configure agent names and global event names
        uvm_config_db#(string)::set(this, "tx_agt*",  "irq_name",   "TX");
        uvm_config_db#(string)::set(this, "tx_agt*",  "event_name", EV_TX_IRQ);

        uvm_config_db#(string)::set(this, "rx_agt*",  "irq_name",   "RX");
        uvm_config_db#(string)::set(this, "rx_agt*",  "event_name", EV_RX_IRQ);

        uvm_config_db#(string)::set(this, "err_agt*", "irq_name",   "ERR");
        uvm_config_db#(string)::set(this, "err_agt*", "event_name", EV_ERR_IRQ);

        // Create 3 agents
        tx_agt  = irq_agt::type_id::create("tx_agt",  this);
        rx_agt  = irq_agt::type_id::create("rx_agt",  this);
        err_agt = irq_agt::type_id::create("err_agt", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Forward transactions from all 3 agents to the aggregated ap port
        tx_agt.ap.connect(fwd_imp);
        rx_agt.ap.connect(fwd_imp);
        err_agt.ap.connect(fwd_imp);
    endfunction

    // Imp write callback to forward items out of ifs_env
    virtual function void write(irq_item t);
        ap.write(t);
    endfunction

    // Query methods (abstract away direct interface access)
    function bit get_txifs();       return tx_agt.get_level(); endfunction
    function bit get_rxifs();       return rx_agt.get_level(); endfunction
    function bit get_errifs();      return err_agt.get_level(); endfunction
    function bit [2:0] get_level(); return {err_agt.get_level(), rx_agt.get_level(), tx_agt.get_level()}; endfunction
    function bit is_pending();      return tx_agt.is_pending() | rx_agt.is_pending() | err_agt.is_pending(); endfunction
endclass

