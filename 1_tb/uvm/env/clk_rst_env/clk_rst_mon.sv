//===========================================================================
//-- Author         : kido
//-- Name           : clk_rst_mon (apb master monitor)
//-- History        : ver.1.00 (26/10/5) 1st release
//--                :
//===========================================================================
class clk_rst_mon extends uvm_monitor;
    `uvm_component_utils(clk_rst_mon)

    virtual clk_rst_if vif;
    // port to scoreboard
    uvm_analysis_port #(rst_item)   as_port;
    function new (string name, uvm_component parent);
        super.new (name, parent);
    endfunction
    // build phase: get vif
    virtual function void build_phase (uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase (phase);
        
        // create here
        as_port = new ("as_port", this);
        
        // get vif
        if (! uvm_config_db #(virtual clk_rst_if) :: get (this, "", "clk_rst_vif", vif)) begin  
            `uvm_fatal ("NOT_IF", "interface not found")
        end
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    // run phase
    virtual task run_phase (uvm_phase phase);
        rst_item item = rst_item::type_id::create("item");
        forever begin
            wait(!vif.rst_n);
            item.rst_time = $time;
            wait(vif.rst_n);
            item.rst_time = $time - item.rst_time;
            as_port.write(item);
        end
    endtask

endclass
