//===========================================================================
//-- Author         : manhndd
//-- Name           : irq_mon (single-line interrupt monitor)
//-- History        : ver.1.00 (26/11/07) Single-line reusable IRQ monitor
//===========================================================================
class irq_mon extends uvm_monitor;
    `uvm_component_utils(irq_mon)

    virtual irq_if vif;
    uvm_analysis_port #(irq_item) ap;

    string irq_name   = "irq";
    string event_name = "irq_ev";
    uvm_event irq_ev;

    bit check_interrupt_pending = 0; // set by ifs_env; 0 = do not flag pending IRQ at end of test
    bit level;
    int unsigned n_rise;
    int unsigned n_fall;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);

        if (!uvm_config_db#(virtual irq_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("irq_if not found in %s", get_full_name()))
        end

        void'(uvm_config_db#(string)::get(this, "", "irq_name", irq_name));
        void'(uvm_config_db#(string)::get(this, "", "event_name", event_name));
        void'(uvm_config_db#(bit)::get(this, "", "check_interrupt_pending", check_interrupt_pending));

        // Connect to named event in global pool
        irq_ev = uvm_event_pool::get_global(event_name);
    endfunction

    virtual task run_phase(uvm_phase phase);
        bit last = 0;
        forever begin
            level = 0;
            last  = 0;
            irq_ev.reset();
            wait (vif.rst_n === 1'b1);
            forever begin
                @(vif.mon_if or negedge vif.rst_n);
                if (!vif.rst_n) break;
                if (vif.mon_if.irq !== last) begin
                    irq_item it  = irq_item::type_id::create("it");
                    it.irq_name  = irq_name;
                    it.level     = vif.mon_if.irq;
                    it.timestamp = $realtime;
                    last         = vif.mon_if.irq;
                    level        = last;

                    if (it.level) begin
                        n_rise++;
                        irq_ev.trigger();
                    end else begin
                        n_fall++;
                        irq_ev.reset();
                    end

                    `uvm_info("IRQ_MON", it.convert2string(), UVM_MEDIUM)
                    ap.write(it);
                end
            end
        end
    endtask

    function bit get_level();  return level; endfunction
    function bit is_pending(); return level; endfunction

    // Catch any interrupt left pending (unserviced) at end of simulation
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (check_interrupt_pending && level) begin
            `uvm_error("PENDING_IRQ", $sformatf("[%s_IRQ] Interrupt line still pending (asserted high) at end of test!", irq_name))
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("IRQ_MON", $sformatf("[%s_IRQ] stats: rises=%0d falls=%0d", irq_name, n_rise, n_fall), UVM_LOW)
    endfunction
endclass

