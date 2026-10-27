//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_env (vsuart environment)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                : ver.1.01 (26/10/20) register layer moved to ral_env,
//--                :                     no analysis imps / write methods
//--                : ver.1.02 (26/10/21) clk_rst agent passed to reg_env (mirror reset)
//--                : ver.1.03 (26/10/21) reg_env no longer takes the clk_rst agent
//--                : ver.1.04 (26/10/21) clk_rst agent passed to reg_env again (ral_rst_sub)
//--                : ver.1.05 (26/10/23) ral_cfg via config_db, reg_env connected in connect_phase
//--                : ver.1.06 (26/10/24) add scb, connect scb with mon
//--                : ver.1.07 (26/10/25) uart_cfg passed to scb
//===========================================================================
class vsuart_env extends uvm_env;
    `uvm_component_utils(vsuart_env)

    clk_rst_agt clk_rst;
    apb_mst_agt apb_agt;
    uart_agt    uart;
    ifs_agt     ifs;
    ral_env     reg_env;  // register model + adapter + predictor
    vsuart_cfg  cfg;
    vsuart_scb  scb;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase(phase);

        if (! uvm_config_db #(vsuart_cfg) :: get (this, "", "cfg", cfg)) begin
            `uvm_fatal ("NOT_CFG", "vsuart configured not found")
        end

        // set clk cfg
        uvm_config_db #(clk_cfg) :: set (this, "*", "c_cfg", cfg.c_cfg);

        // set uart cfg
        uvm_config_db #(uart_cfg) :: set (this, "*", "uart_cfg", cfg.u_cfg);

        // set ral cfg
        uvm_config_db #(ral_cfg) :: set (this, "reg_env", "ral_cfg", cfg.r_cfg);

        // initialize
        clk_rst  = clk_rst_agt::type_id::create("clk_rst", this);
        apb_agt  = apb_mst_agt::type_id::create("apb_agt", this);
        uart     = uart_agt::type_id::create("uart", this);
        ifs      = ifs_agt::type_id::create("ifs", this);
        reg_env  = ral_env::type_id::create("reg_env", this);
        scb      = vsuart_scb::type_id::create("scb", this);

        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...", UVM_LOW)
        super.connect_phase(phase);

        // register predictor <-> apb mon
        reg_env.ral.default_map.set_sequencer(apb_agt.seqr, reg_env.adp);
        apb_agt.mon.as_port.connect(reg_env.pred.bus_in);

        // register layer <-> clk_rst agent: mirror reset on rst_n release
        clk_rst.mon.as_port.connect(reg_env.rst_sub.analysis_export);
        
        // scb <-> mon
        apb_agt.mon.as_port.connect(scb.apb_mst_ap_imp);
        uart.mon.as_tx_port.connect(scb.uart_tx_ap_imp);
        uart.mon.as_rx_port.connect(scb.uart_rx_ap_imp);
        clk_rst.mon.as_port.connect(scb.rst_ap_imp);
        ifs.mon.as_port.connect(scb.ifs_ap_imp);
        `uvm_info("connect_phase", "Exit...", UVM_LOW)
    endfunction
endclass
