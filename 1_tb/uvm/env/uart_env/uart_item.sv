//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_item
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================

class uart_item extends uvm_sequence_item;                     
//for sequence generate
  rand bit [8:0]       data;        
  bit                  parity_error;   // 1 -> send a wrong parity bit on purpose
  bit                  frame_error;
  time start_time;                   // when the start bit began
  time end_time;                     // when the last stop bit ended

   `uvm_object_utils_begin(uart_item)
        `uvm_field_int(data, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(parity_error,UVM_ALL_ON)
        `uvm_field_int(frame_error, UVM_ALL_ON)
        `uvm_field_int(start_time,UVM_ALL_ON)
        `uvm_field_int(end_time,  UVM_ALL_ON)
    `uvm_object_utils_end
  
  function new(string name = "uart_item");
    super.new(name);
     parity_error = 0;   // 1 -> send a wrong parity bit on purpose
     frame_error = 0;
  endfunction

endclass
