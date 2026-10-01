//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/01/10
//-- Author          : kido
//-- IP Name         : uart_rx_controller
//-- History         : ver.1.00 (26/01/10)
//--                 :
//===========================================================================
module uart_rx_controller (
    input               clk,
    input               rst_n,
    input               i_rx_en,
    input               i_rx_pulse,
    input               i_sample_en,
    input               i_mode_stop,            //-- 0: 1-stop-bit, 1: 2-stop-bits
    input  [1 : 0]      i_mode_pdata,           //-- 'b11: 9-bit data, no parity
                                                //-- 'b10: 8-bit data, even parity
                                                //-- 'b01:  8-bit data, odd parity
                                                //-- 'b00:  8-bit data, no parity
    input               i_parity,               //-- from parity generator
    output              o_srt_shift_right,      
    output              o_idle_st,              // 1: fsm in idle state
                                                // 0: fsm in other states   
    output              o_fifo_wr_en,      
    output              o_parity_err,      
    output              o_frame_err
);
// FSM STATE HERE------------------------------------------------------------
    localparam  ST_IDLE          = 3'd0;
    localparam  ST_START_BIT     = 3'd1;
    localparam  ST_DATA_FRAME    = 3'd2;
    localparam  ST_PARITY_BIT    = 3'd3;
    localparam  ST_STOP_BIT      = 3'd4;
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg [2  : 0]    cur_st;
    reg [2  : 0]    nxt_st;
//---------------------------------------------------------------------------
    // output of FSM
//---------------------------------------------------------------------------
    // determine next state, and output
//---------------------------------------------------------------------------
    // determine output
//---------------------------------------------------------------------------
endmodule
//===========================================================================