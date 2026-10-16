//===========================================================================
//-- Author         : kido
//-- Name           : clk_rst_drv (clk_rst driver)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class clk_rst_drv extends uvm_driver #(rst_item);
    `uvm_component_utils(clk_rst_drv)
    
    virtual clk_rst_if vif;
    clk_cfg cfg;
    rst_item item;
    bit is_rst = 0;

    function new (string name, uvm_component parent);
        super.new (name, parent);
    endfunction
    
    // build phase: get vif, cfg
    virtual function void build_phase (uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase (phase);
        // get vif
        if (! uvm_config_db #(virtual clk_rst_if) :: get (this, "", "clk_rst_vif", vif)) begin
            `uvm_fatal ("NOT_IF", "DUT interface not found")
        end
        // get cfg
        if (! uvm_config_db #(clk_cfg) :: get (this, "", "c_cfg", cfg)) begin
            `uvm_fatal ("NOT_CFG", "clk_rst configured not found")
        end
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction


    //run phase
    virtual task run_phase (uvm_phase phase);
        fork
            clk_gen(1, vif.sys_clk, cfg._sys_freq);
            clk_gen(1, vif.apb_clk, cfg._apb_freq);
            // uart clk cant be suspended by reset
            clk_gen(0, vif.uart_clk, cfg._uart_freq);
            rst_gen();
        join
    endtask
    
    // task: clock generation
    task clk_gen(bit is_pending = 1, ref logic clk, int clk_freq);
        int hcycle; // half-cycle, timescale is 100ps/100ps
        int cnt = 0;
        hcycle = int'(1.0/clk_freq * 10_000 / 2);
        forever begin
            cnt = 0;
            if(is_pending) wait(!is_rst);
            forever begin
                #1;
                if(cnt == hcycle) begin
                    clk = ~clk;
                    cnt = 0;
                end else 
                    cnt++;
                if(is_rst && item.rst_type == rst_item::CLK_PENDING && is_pending)
                    break;
            end
        end
    endtask
    
    // task: reset generation
    task rst_gen;
        forever begin
            seq_item_port.get(item);
            is_rst = 1;
            
            #(1 * item.interval_time);
            vif.rst_n = 0;
            #(1 * item.rst_time);
            vif.rst_n = 1;

            is_rst = 0;
            seq_item_port.put(item);
        end
    endtask
endclass


