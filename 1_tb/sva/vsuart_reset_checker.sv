//===========================================================================
//-- Author          : manhndd
//-- Name            : vsuart_reset_checker
//-- Description     : SVA checker verifying default values of all internal registers and top-level output pins.
//-- History         : ver.1.00 (26/11/08) 
//===========================================================================

import uvm_pkg::*;
`include "uvm_macros.svh"

module vsuart_reset_checker #(
)(
  input logic                  clk,
  input logic                  rst_n,

  // VSUART Registers
  input logic [`DATA_W-1:0]     vsuart_reg_mode,
  input logic [`DATA_W-1:0]     vsuart_reg_cr,
  input logic [`DATA_W-1:0]     vsuart_reg_sta,
  input logic [`DATA_W-1:0]     vsuart_reg_brg,
  input logic [`DATA_W-1:0]     vsuart_reg_ie,
  input logic [`DATA_W-1:0]     vsuart_reg_ifs,

  // Top-level Output Pins
  input logic                  o_pready,
  input logic                  o_pslverr,
  input logic                  o_tx,
  input logic                  o_txifs,
  input logic                  o_rxifs,
  input logic                  o_errifs
);

  // Expected Reset Values for Registers
  localparam logic [`DATA_W-1:0] EXP_RESET_MODE = `VSUART_MODE_POR; // 32'h0001_0000 (PDSEL=1)
  localparam logic [`DATA_W-1:0] EXP_RESET_CR   = `VSUART_CR_POR;   // 32'h0000_0000
  localparam logic [`DATA_W-1:0] EXP_RESET_STA  = `VSUART_STA_POR;  // 32'h0000_0024 (TISTA=1, RISTA=1)
  localparam logic [`DATA_W-1:0] EXP_RESET_BRG  = `VSUART_BRG_POR;  // 32'h0000_0001 (BRG=1)
  localparam logic [`DATA_W-1:0] EXP_RESET_IE   = `VSUART_IE_POR;   // 32'h0000_0000
  localparam logic [`DATA_W-1:0] EXP_RESET_IFS  = `VSUART_IFS_POR;  // 32'h0000_0000


  // Expected Reset Values for Top-level Output Pins
  localparam logic               EXP_RESET_PREADY  = 1'b1;        
  localparam logic               EXP_RESET_PSLVERR = 1'b0;        
  localparam logic               EXP_RESET_TX      = 1'b1;        
  localparam logic               EXP_RESET_TXIFS   = 1'b0;        
  localparam logic               EXP_RESET_RXIFS   = 1'b0;        
  localparam logic               EXP_RESET_ERRIFS  = 1'b0;    



  property p_reset_value(act, exp);
    @(negedge rst_n) 1 |=> @(posedge clk) (act === exp);
  endproperty

  // Register Reset Assertions
  A_CHECK_RESET_MODE: assert property (p_reset_value(vsuart_reg_mode, EXP_RESET_MODE))
    else $error("[SVA FAIL] vsuart_reg_mode reset mismatch: act=0x%0h, exp=0x%0h", $sampled(vsuart_reg_mode), EXP_RESET_MODE);

  A_CHECK_RESET_CR: assert property (p_reset_value(vsuart_reg_cr, EXP_RESET_CR))
    else $error("[SVA FAIL] vsuart_reg_cr reset mismatch: act=0x%0h, exp=0x%0h", $sampled(vsuart_reg_cr), EXP_RESET_CR);

  A_CHECK_RESET_STA: assert property (p_reset_value(vsuart_reg_sta, EXP_RESET_STA))
    else $error("[SVA FAIL] vsuart_reg_sta reset mismatch: act=0x%0h, exp=0x%0h", $sampled(vsuart_reg_sta), EXP_RESET_STA);

  A_CHECK_RESET_BRG: assert property (p_reset_value(vsuart_reg_brg, EXP_RESET_BRG))
    else $error("[SVA FAIL] vsuart_reg_brg reset mismatch: act=0x%0h, exp=0x%0h", $sampled(vsuart_reg_brg), EXP_RESET_BRG);

  A_CHECK_RESET_IE: assert property (p_reset_value(vsuart_reg_ie, EXP_RESET_IE))
    else $error("[SVA FAIL] vsuart_reg_ie reset mismatch: act=0x%0h, exp=0x%0h", $sampled(vsuart_reg_ie), EXP_RESET_IE);

  A_CHECK_RESET_IFS: assert property (p_reset_value(vsuart_reg_ifs, EXP_RESET_IFS))
    else $error("[SVA FAIL] vsuart_reg_ifs reset mismatch: act=0x%0h, exp=0x%0h", $sampled(vsuart_reg_ifs), EXP_RESET_IFS);

  // Output Pin Reset Assertions
  A_CHECK_RESET_PREADY: assert property (p_reset_value(o_pready, EXP_RESET_PREADY))
    else $error("[SVA FAIL] o_pready reset mismatch: act=0x%0h, exp=0x%0h", $sampled(o_pready), EXP_RESET_PREADY);

  A_CHECK_RESET_PSLVERR: assert property (p_reset_value(o_pslverr, EXP_RESET_PSLVERR))
    else $error("[SVA FAIL] o_pslverr reset mismatch: act=0x%0h, exp=0x%0h", $sampled(o_pslverr), EXP_RESET_PSLVERR);

  A_CHECK_RESET_TX: assert property (p_reset_value(o_tx, EXP_RESET_TX))
    else $error("[SVA FAIL] o_tx reset mismatch: act=0x%0h, exp=0x%0h", $sampled(o_tx), EXP_RESET_TX);

  A_CHECK_RESET_TXIFS: assert property (p_reset_value(o_txifs, EXP_RESET_TXIFS))
    else $error("[SVA FAIL] o_txifs reset mismatch: act=0x%0h, exp=0x%0h", $sampled(o_txifs), EXP_RESET_TXIFS);

  A_CHECK_RESET_RXIFS: assert property (p_reset_value(o_rxifs, EXP_RESET_RXIFS))
    else $error("[SVA FAIL] o_rxifs reset mismatch: act=0x%0h, exp=0x%0h", $sampled(o_rxifs), EXP_RESET_RXIFS);

  A_CHECK_RESET_ERRIFS: assert property (p_reset_value(o_errifs, EXP_RESET_ERRIFS))
    else $error("[SVA FAIL] o_errifs reset mismatch: act=0x%0h, exp=0x%0h", $sampled(o_errifs), EXP_RESET_ERRIFS);

  // Cover properties: reset state reached (non-vacuous) for registers and pins
  C_ALL_REG_RESET_OK: cover property (
    @(posedge clk) (rst_n === 1'b0) &&
    (vsuart_reg_mode === EXP_RESET_MODE) &&
    (vsuart_reg_cr   === EXP_RESET_CR)   &&
    (vsuart_reg_sta  === EXP_RESET_STA)  &&
    (vsuart_reg_brg  === EXP_RESET_BRG)  &&
    (vsuart_reg_ie   === EXP_RESET_IE)   &&
    (vsuart_reg_ifs  === EXP_RESET_IFS)
  );

  C_ALL_PIN_RESET_OK: cover property (
    @(posedge clk) (rst_n === 1'b0) &&
    (o_pready  === EXP_RESET_PREADY)  &&
    (o_pslverr === EXP_RESET_PSLVERR) &&
    (o_tx      === EXP_RESET_TX)      &&
    (o_txifs   === EXP_RESET_TXIFS)   &&
    (o_rxifs   === EXP_RESET_RXIFS)   &&
    (o_errifs  === EXP_RESET_ERRIFS)
  );

  // Cover property to ensure the reset event is stimulated
  C_RESET_ASSERT: cover property (@(negedge rst_n) 1'b1);


endmodule

//===========================================================================

bind tb_vsuart vsuart_reset_checker u_vsuart_reset_checker (
  .clk              (u_dut.sys_clk),
  .rst_n            (u_dut.rst_n),
  .vsuart_reg_mode  (u_dut.u_vsuart_reg.reg_mode),
  .vsuart_reg_cr    (u_dut.u_vsuart_reg.reg_cr),
  .vsuart_reg_sta   (u_dut.u_vsuart_reg.reg_sta),
  .vsuart_reg_brg   (u_dut.u_vsuart_reg.reg_brg),
  .vsuart_reg_ie    (u_dut.u_vsuart_reg.reg_ie),
  .vsuart_reg_ifs   (u_dut.u_vsuart_reg.reg_ifs),
  .o_pready         (u_dut.o_pready),
  .o_pslverr        (u_dut.o_pslverr),
  .o_tx             (u_dut.o_tx),
  .o_txifs          (u_dut.o_txifs),
  .o_rxifs          (u_dut.o_rxifs),
  .o_errifs         (u_dut.o_errifs)
);
//===========================================================================