//===========================================================================
//-- Author         : kido
//-- Name           : clk_rst_agt (clk reset agent)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class clk_rst_agt extends uvm_agent;
    `uvm_component_utils(clk_rst_agt)

    clk_rst_drv drv;
    clk_rst_seqr seqr;
    clk_rst_mon mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `uvm_info("build_phase", "Entered...", UVM_LOW)
        super.build_phase(phase);

        drv  = clk_rst_drv::type_id::create("drv", this);
        seqr = clk_rst_seqr::type_id::create("seqr", this);
        mon  = clk_rst_mon::type_id::create("mon", this);
        `uvm_info("build_phase", "Exit...", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        `uvm_info("connect_phase", "Entered...", UVM_LOW)
        drv.seq_item_port.connect(seqr.seq_item_export);
        `uvm_info("connect_phase", "Exit...", UVM_LOW)
    endfunction

endclass
