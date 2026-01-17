
//-- UVM Package and Macros
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "apb_if.sv"
//-- Test-related Includes
`include "test_top.sv"

//--------------------------------------------------------------------
// Module: top_test
// Description:
//   Top-level module for the APB UVM testbench using apb_dut_wrapper.
//   Instantiates DUT wrapper and APB interfaces (slave/master),
//   starts UVM test.
//--------------------------------------------------------------------

module top_test();

  //-- APB Slave Interface (input side to DUT)
  apb_if slave_vif();

  //-- APB Master Interface (output side from DUT)
  apb_if master_vif();  

  //--------------------------------------------------------------------
  //-- Clock Generation
  //--------------------------------------------------------------------
  initial begin
    slave_vif.pclk = 1'b0;
    forever #5 slave_vif.pclk = ~slave_vif.pclk;
  end

  assign master_vif.pclk = slave_vif.pclk;

  //--------------------------------------------------------------------
  //-- Reset Generation
  //--------------------------------------------------------------------
  initial begin
    slave_vif.presetn = 1'b1;
    #15;
    slave_vif.presetn = 1'b0;
    #20;
    slave_vif.presetn = 1'b1;
  end

  assign master_vif.presetn = slave_vif.presetn;
  
  
  //-- DUT Wrapper Instance
  apb_dut_wrapper u_top_wrapper (  	
    // Slave side (inputs)
    .pclk      (slave_vif.pclk),
    .presetn   (slave_vif.presetn),
    .s_paddr   (slave_vif.paddr),
    .s_pwrite  (slave_vif.pwrite),
    .s_psel    (slave_vif.psel),
    .s_penable (slave_vif.penable),
    .s_pwdata  (slave_vif.pwdata),
    .s_pstrb   (slave_vif.pstrb),
    .s_pprot   (slave_vif.pprot),
    .s_prdata  (slave_vif.prdata),
    .s_pready  (slave_vif.pready),
    .s_pslverr (slave_vif.pslverr),

    // Master side (outputs)
    .m_paddr   (master_vif.paddr),
    .m_pwrite  (master_vif.pwrite),
    .m_psel    (master_vif.psel),
    .m_penable (master_vif.penable),
    .m_pwdata  (master_vif.pwdata),
    .m_pstrb   (master_vif.pstrb),
    .m_pprot   (master_vif.pprot),
    .m_prdata  (master_vif.prdata),
    .m_pready  (master_vif.pready),
    .m_pslverr (master_vif.pslverr),
    
    //Uart interface
    .uart_clk  (slave_vif.pclk),
    .rst_n     (slave_vif.presetn)
  );

  //--------------------------------------------------------------------
  //-- UVM Test Execution
  //--------------------------------------------------------------------
  initial begin
    //-- Set virtual interface(s) for testbench
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", slave_vif);
    uvm_config_db#(virtual apb_if)::set(null, "*", "m_vif", master_vif);

    //-- Run the test
    run_test();
  end

  //--------------------------------------------------------------------
  //-- Waveform Dumping
  //--------------------------------------------------------------------
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
  end

endmodule
