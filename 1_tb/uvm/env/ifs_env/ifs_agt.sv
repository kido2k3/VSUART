//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_agt
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
class ifs_agt extends uvm_agent;
    `uvm_component_utils(ifs_agt)

    ifs_mon mon;  // passive
    uvm_analysis_port #(ifs_item) as_port;  // for scoreboard 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase(phase);
        as_port = new("as_port", this);
        mon = ifs_mon::type_id::create("mon", this);
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...", UVM_LOW)
        mon.as_port.connect(as_port);  // connect to scoreboard
        `uvm_info("connect_phase", "Exit...", UVM_LOW)
    endfunction
endclass
