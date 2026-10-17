//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_mon (interrupt monitor)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                : publish an ifs_item whenever a line changes level
//===========================================================================
class ifs_mon extends uvm_monitor;
    `uvm_component_utils(ifs_mon)

    virtual ifs_if vif;

    // port to scoreboard
    uvm_analysis_port #(ifs_item) as_port;  

    bit [2:0] level;  // last captured status data
    int unsigned n_rise[3];  // 0->1 count per line: [0] tx, [1] rx, [2] err

    function new (string name, uvm_component parent);
        super.new (name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase (phase);

        as_port = new ("as_port", this);

        // get vif
        if (! uvm_config_db #(virtual ifs_if) :: get (this, "", "ifs_vif", vif)) begin
            `uvm_fatal ("NOT_IF", "interface not found")
        end
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    virtual task run_phase (uvm_phase phase);
        bit [2:0] now;
        ifs_item item;
        forever begin
            level = 0;  
            wait (vif.rst_n === 1'b1);  // start after reset release
            forever begin
                @(vif.mon_if or negedge vif.rst_n);  // each apb_clk edge
                if (!vif.rst_n) break;
                now = {vif.mon_if.errifs, vif.mon_if.rxifs, vif.mon_if.txifs};
                if (now !== level) begin  // publish only on change
                    item = ifs_item::type_id::create("item");
                    {item.errifs, item.rxifs, item.txifs} = now;
                    item.changed = now ^ level;  
                    foreach (n_rise[i]) 
                        if (now[i] && !level[i]) n_rise[i]++;
                    
                    level = now;
                    `uvm_info("MON_IFS", item.convert2string(), UVM_MEDIUM)
                    as_port.write(item);
                end
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("MON_IFS", $sformatf("interrupt rises: txifs=%0d rxifs=%0d errifs=%0d",
                  n_rise[0], n_rise[1], n_rise[2]), UVM_LOW)
    endfunction
endclass
