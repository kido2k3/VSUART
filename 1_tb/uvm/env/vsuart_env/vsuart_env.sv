//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_env (vsuart environment)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                : ver.1.01 (26/10/17) add apb agent + register layer
//--                :          (ral, apb_reg_adapter, vsuart_reg_predictor)
//===========================================================================
class vsuart_env extends uvm_agent;
    `uvm_component_utils(vsuart_env)

    clk_rst_agt clk_rst;
    apb_mst_agt apb_agt;
    vsuart_cfg cfg;

    // register layer
    vsuart_reg_block ral;
    apb_reg_adapter adapter;
    vsuart_reg_predictor predictor;

    // observed reset (from clk_rst monitor) -> reset ral mirror
    uvm_analysis_imp #(rst_item, vsuart_env) rst_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase(phase);
        // get cfg
        if (! uvm_config_db #(vsuart_cfg) :: get (this, "", "cfg", cfg)) begin
            `uvm_fatal ("NOT_CFG", "vsuart configured not found")
        end

        // set cfg
        uvm_config_db #(clk_cfg) :: set (this, "*", "c_cfg", cfg.c_cfg);
        // initialize
        clk_rst  = clk_rst_agt::type_id::create("clk_rst", this);
        apb_agt  = apb_mst_agt::type_id::create("apb_agt", this);
        rst_imp  = new("rst_imp", this);

        // register layer: uvm_reg_block is not a uvm_component
        ral = vsuart_reg_block::type_id::create({get_full_name(), ".ral"});
        ral.build(cfg.base_addr);
        adapter   = apb_reg_adapter::type_id::create("adapter");
        predictor = vsuart_reg_predictor::type_id::create("predictor", this);

        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...", UVM_LOW)
        // frontdoor: ral -> adapter.reg2bus -> apb sequencer
        ral.default_map.set_sequencer(apb_agt.seqr, adapter);
        // explicit prediction: every observed apb transfer updates the mirror
        predictor.map     = ral.default_map;
        predictor.adapter = adapter;
        apb_agt.mon.as_port.connect(predictor.bus_in);
        // reset the mirror after every observed rst_n pulse
        clk_rst.mon.as_port.connect(rst_imp);
        `uvm_info("connect_phase", "Exit...", UVM_LOW)
    endfunction

    // function: called by clk_rst monitor when rst_n is released.
    function void write(rst_item t);
        `uvm_info("RAL", "System reset observed, reset register model", UVM_LOW)
        ral.reset("HARD");
    endfunction

endclass
