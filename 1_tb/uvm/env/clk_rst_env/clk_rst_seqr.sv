//===========================================================================
//-- Author         : kido
//-- Name           : clk_rst_seqr (clk reset sequencer)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class clk_rst_seqr extends uvm_sequencer #(rst_item);
    `uvm_component_utils(clk_rst_seqr)

    function new(string name = "clk_rst_seqr", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
