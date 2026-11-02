class vsuart_tx_basic_test extends base_test;
    `uvm_component_utils(vsuart_tx_basic_test)

    function new(string name = "vsuart_tx_basic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_tx_basic_seq::get_type());
        super.build_phase(phase);
        // Section 6 defaults PRS=1, BRG=728, BSEL=1 target 9600 at 112 MHz.
        cfg.set_sys_freq(112);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            begin
                fork
                    super.run_phase(phase);
                    begin
                        #30ms;
                        `uvm_fatal("TX_BASIC_TIMEOUT", "TX basic did not complete within 30 ms")
                    end
                join_any
                disable fork;
            end
        join
    endtask
endclass
