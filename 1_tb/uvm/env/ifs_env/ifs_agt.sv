//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_agt
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
class ifs_agt extends uvm_agent;
    `uvm_component_utils(ifs_agt)

    ifs_mon mon;  // passive

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase(phase);
        mon = ifs_mon::type_id::create("mon", this);
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction
endclass
