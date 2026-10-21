//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_rst_sub (register mirror reset on rst_n release)
//-- History        : ver.1.00 (26/10/21) 1st release
//===========================================================================

//subscriber connect to clk_rst_monitor 
class ral_rst_sub extends uvm_subscriber #(rst_item);
    `uvm_component_utils(ral_rst_sub)

    ral_blk ral;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void write(rst_item t);
        `uvm_info("RAL_RST", $sformatf("rst_n released (low for %0d): reset mirror of %s",
                  t.rst_time, ral.get_full_name()), UVM_MEDIUM)
        ral.reset("HARD");
    endfunction
endclass
