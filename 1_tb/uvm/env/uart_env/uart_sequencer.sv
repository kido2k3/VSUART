//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_sequencer
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================

class uart_sequencer extends uvm_sequencer #(uart_item);
 `uvm_component_utils(uart_sequencer)

 function new(string name = "uart_sequencer", uvm_component parent);
    super.new(name, parent);
 endfunction
endclass
