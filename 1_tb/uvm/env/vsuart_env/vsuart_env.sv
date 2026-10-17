//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_env (vsuart environment)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class vsuart_env extends uvm_agent;
    `uvm_component_utils(vsuart_env)

    clk_rst_agt clk_rst;
    vsuart_cfg cfg;
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

        // set clock for uart
        cfg.uart_cfg.sys_clk_freq = cfg.c_cfg._sys_freq * 1_000_000;
        uvm_config_db #(uart_cfg) :: set (this, "uart.*", "uart_cfg", cfg.uart_cfg);
        
        // initialize
        clk_rst  = clk_rst_agt::type_id::create("clk_rst", this);

        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...", UVM_LOW)
        `uvm_info("connect_phase", "Exit...", UVM_LOW)
    endfunction

endclass
