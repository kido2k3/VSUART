//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_env (vsuart environment)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                : ver.1.01 (26/10/20) register layer moved to ral_env,
//--                :                     no analysis imps / write methods
//--                : ver.1.02 (26/10/21) clk_rst agent passed to reg_env (mirror reset)
//--                : ver.1.03 (26/10/21) reg_env no longer takes the clk_rst agent
//--                : ver.1.04 (26/10/21) clk_rst agent passed to reg_env again (ral_rst_sub)
//===========================================================================
class vsuart_env extends uvm_env;
    `uvm_component_utils(vsuart_env)

    clk_rst_agt clk_rst;
    apb_mst_agt apb_agt;
    uart_agt    uart;
    ifs_agt     ifs;
    ral_env     reg_env;  // register model + adapter + predictor
    vsuart_cfg  cfg;

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
        uvm_config_db #(uart_cfg) :: set (this, "uart*", "uart_cfg", cfg.u_cfg);

        // initialize
        clk_rst  = clk_rst_agt::type_id::create("clk_rst", this);
        apb_agt  = apb_mst_agt::type_id::create("apb_agt", this);
        uart     = uart_agt::type_id::create("uart", this);
        ifs      = ifs_agt::type_id::create("ifs", this);
        reg_env  = ral_env::type_id::create("reg_env", this);
        reg_env.base_addr = cfg.base_addr;
        reg_env.apb_agt   = apb_agt;
        reg_env.rst_agt   = clk_rst;

        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction
endclass
