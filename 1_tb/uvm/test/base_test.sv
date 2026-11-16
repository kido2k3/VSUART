//===========================================================================
//-- Author         : kido
//-- Name           : base_test
//-- History        : ver.1.00 (26/10/14) 1st release
//--                : ver.1.01 (26/10/17) connect apb sequencer + ral to vseq
//--                : ver.1.02 (26/10/17) connect uart sequencer to vseq
//--                : ver.1.03 (26/10/20) ral from env.reg_env, uart_cfg to vseq
//--                :
//===========================================================================
class base_test extends uvm_test;

    `uvm_component_utils(base_test) 
    vsuart_cfg cfg;
    vsuart_env env;
    virtual sva_if sva_vif;   // SVA enables/counters, all enabled by default
    vsuart_base_seq seq;
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase(phase);
        // default run_phase timeout
        uvm_top.set_timeout(1s, 1);
        // override here
        //...
        
        // get configuration here
        if (! uvm_config_db #(vsuart_cfg) :: get (this, "", "cfg", cfg)) begin
            cfg = vsuart_cfg::type_id::create("cfg");
        end

        cfg.set_sys_freq(112);
        //...
        
        // SVA control interface: all checks enabled, a test disables what it must
        if (!uvm_config_db #(virtual sva_if)::get(this, "", "sva_vif", sva_vif))
            `uvm_fatal("NOVIF", "sva_vif not found")

        // set configuration here
        uvm_config_db #(vsuart_cfg) :: set (this, "*", "cfg", cfg);
        //...

        // create here
        env = vsuart_env::type_id::create("env", this);
        seq = vsuart_base_seq::type_id::create("seq", this);
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction
        
    function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
        
        uvm_top.print_topology();
        `uvm_info("default_cfg", cfg.sprint(), UVM_LOW)

        `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...", UVM_LOW)
        connect_env_with_seq();
        // after every build_phase: a derived test may have changed sys_freq
        sva_vif.sys_freq_mhz = cfg.c_cfg._sys_freq;
        `uvm_info("connect_phase", "Exit...", UVM_LOW)
    endfunction

    // function: connect virtual sequence with sequencer
    function void connect_env_with_seq();
        seq.r_seqr = env.clk_rst.seqr;
        seq.a_seqr = env.apb_agt.seqr;
        seq.u_seqr = env.uart.sqr;
        seq.ral    = env.reg_env.ral;
        seq.cfg    = cfg;
        seq.sva_vif = sva_vif;
    endfunction
    // run phase
    virtual task run_phase (uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("run_phase", "Entered...", UVM_LOW)
        seq.start(null);
        `uvm_info("run_phase", "Exit...", UVM_LOW)
        phase.drop_objection(this);
    endtask

    function void final_phase(uvm_phase phase);
        uvm_report_server svr;
        `uvm_info("final_phase", "Entered...",UVM_LOW)

        super.final_phase(phase);

        svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) > 0) 
            `uvm_error("Result", "Test Failed\n")
        else
            `uvm_info("Result", "Test Passed\n", UVM_LOW)
        `uvm_info("final_phase", "Exiting...", UVM_LOW)
    endfunction: final_phase
endclass
