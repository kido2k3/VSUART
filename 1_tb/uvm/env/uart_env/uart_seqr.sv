//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_seqr (uart sequencer)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================

class uart_seqr extends uvm_sequencer #(uart_item);
 `uvm_component_utils(uart_seqr)

 function new(string name = "uart_seqr", uvm_component parent);
    super.new(name, parent);
 endfunction
endclass
