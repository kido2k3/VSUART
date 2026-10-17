//===========================================================================
//-- Author         : Trizrd
//-- Name           : tb_top
//-- History        : ver.1.00 (26/10/16) 1st release
//--                :
//===========================================================================
`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import uart_pkg::*;
  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk;                       // 100 MHz
  
  uart_if uif (clk, rst_n);
  uart_dut_dummy dut (.u_rx(uif.u_rx), .u_tx(uif.u_tx));
  initial begin
    rst_n = 0;
    repeat (10) @(posedge clk);
    rst_n = 1;
  end
  // +WAVE -> xuat wave.vcd
  initial if ($test$plusargs("WAVE")) begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_top);
  end

  initial begin
    uvm_config_db#(virtual uart_if)::set(null, "*", "uart_vif", uif);
    uvm_top.set_timeout(50ms, 0);             // chong treo
    run_test();
  end

endmodule