//===========================================================================
//-- Author : Trizrd
//-- Name : uart_if(uart interface)
//-- History : ver.1.00 (26/10/16) 1st release
//-- :
//===========================================================================
`ifndef UART_INTERFACE_SV
`define UART_INTERFACE_SV

interface uart_if(input clk ,rst_n);
logic u_tx;
logic u_rx;

clocking drv_if @(posedge clk);
 default output #1step;
 output u_rx;
 endclocking

 clocking mon_if @(posedge clk);
 default input #1step;
 input u_rx ,u_tx;
 endclocking

//-----------------------------------------------------------ASSERTION for UART----------------------------------------------------------- 
endinterface
`endif