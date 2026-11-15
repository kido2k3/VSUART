//===========================================================================
//-- Author         : manhndd
//-- Name           : sva_if
//-- Description    : Control interface of the SVA checkers (enables, targets, counters)
//-- History        : ver.1.00 (26/11/14) 1st release
//===========================================================================
interface sva_if;

  // enables bits
  bit rst_chk_en = 1'b1;
  bit tx_chk_en  = 1'b1;
  bit brg_chk_en = 1'b1;

  // baud check (A_TX_BAUD in vsuart_tx_checker)
  int unsigned sys_freq_mhz;          // nominal sys_clk, set by base_test
  int unsigned target_baud  = 0;      // expected baud, 0: no baud check
  real         baud_tol_pct = 2.0;    // allowed |measured - expected| / expected, in %

  // counters (written by the checkers)
  int unsigned n_frames;              // TX frames tracked up to the last stop bit
  int unsigned n_baud_checked;        // frames checked by A_TX_BAUD (target set)

  function automatic void all_off();
    rst_chk_en = 1'b0;
    tx_chk_en  = 1'b0;
    brg_chk_en = 1'b0;
  endfunction

  function automatic void all_on();
    rst_chk_en = 1'b1;
    tx_chk_en  = 1'b1;
    brg_chk_en = 1'b1;
  endfunction

  function automatic string sprint();
    return $sformatf("rst_chk_en=%0b tx_chk_en=%0b brg_chk_en=%0b sys_freq=%0d MHz target_baud=%0d tol=%.3f%% n_frames=%0d n_baud_checked=%0d",
                     rst_chk_en, tx_chk_en, brg_chk_en, sys_freq_mhz, target_baud, baud_tol_pct,
                     n_frames, n_baud_checked);
  endfunction

endinterface
