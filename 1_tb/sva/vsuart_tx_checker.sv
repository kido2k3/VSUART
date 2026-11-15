//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_tx_checker
//-- Description    : SVA checker of the TX line: frame structure and baud rate
//-- History        : ver.1.00 (26/11/13) 1st release (vsuart_brg_checker)
//--                : ver.2.00 (26/11/14) frame tracker, structural checks, enables in sva_if
//--                : ver.3.00 (26/11/14) A_BRG_PERIOD replaced by A_TX_BAUD (any data, tolerance)
//===========================================================================

import uvm_pkg::*;
`include "uvm_macros.svh"

module vsuart_tx_checker (
  input logic                clk,
  input logic                rst_n,
  input logic                tx_en,
  input logic                o_tx,
  input logic [`DATA_W-1:0]  reg_mode,
  input logic [`DATA_W-1:0]  reg_brg,
  sva_if                     sva
);

  logic        tx_q;           // o_tx one sample earlier
  logic        in_frame;
  int unsigned pos;            // nums of clock cycle since the start bit
  int unsigned cyc;            // latched OS*(BRG+1)
  int unsigned nbits;          // latched nums of (start + data + parity + stop)
  int unsigned nstop;          // latched nums of stop bits
  int unsigned target;         // latched sva.target_baud (0: no baud check)

  //OS * (BRG + 1)
  int unsigned bit_cyc;
  assign bit_cyc = (reg_mode[8] ? 4 : 16) * (int'(reg_brg[15:0]) + 1);

  //frame length in bits: start + data + parity + stop
  function automatic int unsigned frame_bits();
    logic [1:0] pdsel = reg_mode[17:16];
    logic       spsel = reg_mode[24];
    return 1 + ((pdsel == 2'b11) ? 9 : 8)
             + ((pdsel inside {2'b01, 2'b10}) ? 1 : 0)
             + (spsel ? 2 : 1);
  endfunction

  wire start_edge = tx_en && !in_frame && tx_q === 1'b1 && o_tx === 1'b0;
  wire frame_end  = in_frame && pos == nbits * cyc - cyc / 2;
  wire frame_edge = in_frame && o_tx !== tx_q;

  // baud = sys_freq / cyc vs target within baud_tol_pct.
  function automatic void check_baud();
    real baud = sva.sys_freq_mhz * 1.0e6 / cyc;
    real err  = 100.0 * (baud - target) / target;
    sva.n_baud_checked++;
    A_TX_BAUD: assert ((err < 0.0 ? -err : err) <= sva.baud_tol_pct)
      `uvm_info("TX_BAUD", $sformatf("PASS BSEL=%0d BRG=%0d: %.2f bps (%0d cycles/bit), target %0d bps, error %+.3f%% (tol %.3f%%)",
                reg_mode[8], reg_brg[15:0], baud, cyc, target, err, sva.baud_tol_pct), UVM_LOW)
    else
      `uvm_error("TX_BAUD", $sformatf("BSEL=%0d BRG=%0d: %.2f bps (%0d cycles/bit), target %0d bps, error %+.3f%% > tol %.3f%%",
                 reg_mode[8], reg_brg[15:0], baud, cyc, target, err, sva.baud_tol_pct))
  endfunction

  //-------------------------------------------------------------------------
  // A falling edge of o_tx outside a frame is a start bit:  are captured, pos counts sys_clk cycles from it.
  // The frame ends in the middle of the last stop bit
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tx_q     <= 1'b1;
      in_frame <= 1'b0;
      pos      <= 0;
      cyc      <= 1;             //avoid % 0
      nbits    <= 0;
      nstop    <= 0;
      target   <= 0;
    end else begin
      tx_q    <= o_tx;
      if (!tx_en) begin
        in_frame <= 1'b0;                 // UEN off: frame aborted
      end else if (start_edge) begin
        in_frame <= 1'b1;               
        
        //capture BSEL/BRG/PDSEL/SPSEL and the target baud
        pos      <= 1;
        cyc      <= bit_cyc;
        nbits    <= frame_bits();
        nstop    <= reg_mode[24] ? 2 : 1;
        target   <= sva.target_baud;
      end else if (in_frame) begin
        pos <= pos + 1;
        if (frame_end) begin
          in_frame <= 1'b0;
          sva.n_frames++;
          if (sva.brg_chk_en && target != 0) check_baud();
        end
      end
    end
  end


  //A_TX_KNOWN      : o_tx never X/Z while TX is enabled  
  A_TX_KNOWN: assert property (
    @(posedge clk) disable iff (!rst_n || !sva.tx_chk_en)
    tx_en |-> !$isunknown(o_tx))
  else `uvm_error("TX_KNOWN", $sformatf("o_tx = %b while TX is enabled", $sampled(o_tx)))

  A_TX_EDGE_ALIGN: assert property (
    @(posedge clk) disable iff (!rst_n || !tx_en || !(sva.tx_chk_en || sva.brg_chk_en))
    frame_edge |-> (pos % cyc == 0))
  else `uvm_error("TX_EDGE_ALIGN", $sformatf("o_tx %b->%b at cycle %0d of the frame, not a multiple of the bit period %0d",
                  $sampled(tx_q), $sampled(o_tx), $sampled(pos), $sampled(cyc)))


endmodule

//===========================================================================

bind tb_vsuart vsuart_tx_checker u_vsuart_tx_checker (
  .clk       (u_dut.sys_clk),
  .rst_n     (u_dut.rst_n),
  .tx_en     (u_dut.tx_en),
  .o_tx      (u_dut.o_tx),
  .reg_mode  (u_dut.u_vsuart_reg.reg_mode),
  .reg_brg   (u_dut.u_vsuart_reg.reg_brg),
  .sva       (sva_vif)
);
//===========================================================================
