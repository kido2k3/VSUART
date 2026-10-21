//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_env (register layer: model + adapter + predictor + subscriber)
//-- History        : ver.1.00 (26/10/20) 1st release
//===========================================================================


//   reg.write()/read() --> default_map --> adp.reg2bus() --> apb_agt.seqr --> DUT
//   apb_agt.mon.as_port --> pred.bus_in --> adp.bus2reg() --> reg.do_predict()
//   rst_agt.mon.as_port --> rst_sub      --> ral.reset("HARD") on rst_n release
// default_map.set_auto_predict(0) is in ral_blk::build().
class ral_env extends uvm_env;
    `uvm_component_utils(ral_env)

    ral_blk                       ral;
    ral_apb_adp                   adp;
    uvm_reg_predictor #(_apb_item) pred;
    ral_rst_sub                   rst_sub;

    apb_mst_agt    apb_agt;          // bus agent, set by parent
    clk_rst_agt    rst_agt;          // reset agent, set by parent
    uvm_reg_addr_t base_addr = 0;    // CSR base address
    bit            cov_en    = 1;    // register / address-map coverage

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (cov_en) uvm_reg::include_coverage("*", UVM_CVR_ALL);
        ral = ral_blk::type_id::create({get_full_name(), ".ral"});
        ral.build(base_addr);
        if (cov_en) void'(ral.set_coverage(UVM_CVR_ALL));
        adp  = ral_apb_adp::type_id::create("adp");
        pred = uvm_reg_predictor #(_apb_item)::type_id::create("pred", this);
        rst_sub = ral_rst_sub::type_id::create("rst_sub", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (apb_agt == null) `uvm_fatal("RAL_ENV", "apb_agt not set by parent")
        ral.default_map.set_sequencer(apb_agt.seqr, adp);
        pred.map     = ral.default_map;
        pred.adapter = adp;
        apb_agt.mon.as_port.connect(pred.bus_in);
        if (rst_agt == null) `uvm_fatal("RAL_ENV", "rst_agt not set by parent")
        rst_sub.ral = ral;
        rst_agt.mon.as_port.connect(rst_sub.analysis_export);
    endfunction
endclass
