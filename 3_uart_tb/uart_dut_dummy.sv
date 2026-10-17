//===========================================================================
//-- Author : Trizrd
//-- Name : uart_dut_dummy
//-- History : ver.1.00 (26/10/16) 1st release
//-- :
//===========================================================================
module uart_dut_dummy (input logic u_rx, output logic u_tx);
 assign u_tx = u_rx;
endmodule