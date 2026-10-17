//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_item
//-- History        : ver.1.00 (26/10/16) 1st release
//--                :
//===========================================================================

class uart_item extends uvm_sequence_item;                     
//for sequence generate
  rand uart_tx_rx_e         uart_dir;
  rand bit [8:0]            data;        
  rand uart_par_e           parity;
  rand bit                  parity_error;   // 1 -> send a wrong parity bit on purpose
  rand bit                  frame_error;
  //for monitor to read
  //bit   frerr;         // Receive Framing Error Status (FRERR)
  //bit   rbosta;        // Receive Buffer Overflow Status (RBOSTA)
  //bit   rbdsta;        // Receive Buffer Data Available (RBDSTA)
  //bit   tbsta;         // Transmit Buffer Full status (TBSTA)
  //bit   trsta;         // Transmit Shift Register empty (TRSTA)
  //bit   parity_err     // Receive Parity error
  time start_time;                   // when the start bit began
  time end_time;                     // when the last stop bit ended

  constraint c_err {
    soft parity_error == 0;  //default not turn on error
    soft frame_error == 0; //default not turn on error
  }
   `uvm_object_utils(uart_item)
  function new(string name = "uart_item");
    super.new(name);
  endfunction

 

  function string convert2string();
    return $sformatf("%s data=0x%03h parity=%s perr=%0b",
                     uart_dir.name(), data, parity.name(), parity_error);// for debug purpose may fix in the incomming version
  endfunction

endclass