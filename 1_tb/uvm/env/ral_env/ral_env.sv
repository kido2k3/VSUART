//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_env (register layer: model + adapter + predictor + subscriber)
//-- History        : ver.1.00 (26/10/20) 1st release
//--                : ver.1.01 (26/10/23) ral_cfg from config_db, agents connected by parent
//===========================================================================


//   reg.write()/read() --> default_map --> adp.reg2bus() --> apb_agt.seqr --> DUT
//   apb_agt.mon.as_port --> pred.bus_in --> adp.bus2reg() --> reg.do_predict()
//   rst_agt.mon.as_port --> rst_sub      --> ral.reset("HARD") on rst_n release
// The agent connections (set_sequencer, bus_in, rst_sub) are made by the parent env.
// default_map.set_auto_predict(0) is in ral_blk::build().
class ral_env extends uvm_env;
    `uvm_component_utils(ral_env)

    ral_blk                       ral;
    ral_apb_adp                   adp;
    uvm_reg_predictor #(_apb_item) pred;
    ral_rst_sub                   rst_sub;
    ral_cfg                       cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (! uvm_config_db #(ral_cfg) :: get (this, "", "ral_cfg", cfg)) begin
            `uvm_fatal("NOT_CFG", "ral configuration not found")
        end
        if (cfg.cov_en) uvm_reg::include_coverage("*", UVM_CVR_ALL);
        ral = ral_blk::type_id::create({get_full_name(), ".ral"});
        ral.build(cfg.base_addr);
        if (cfg.cov_en) void'(ral.set_coverage(UVM_CVR_ALL));
        adp  = ral_apb_adp::type_id::create("adp");
        pred = uvm_reg_predictor #(_apb_item)::type_id::create("pred", this);
        rst_sub = ral_rst_sub::type_id::create("rst_sub", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        pred.map     = ral.default_map;
        pred.adapter = adp;
        rst_sub.ral  = ral;
    endfunction
endclass
