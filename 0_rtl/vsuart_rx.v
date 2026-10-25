//===========================================================================
//-- IP Name         : vsuart_rx
//-- Author          : kido
//-- History         : ver.1.00 (26/01/17)
//--                 :
//===========================================================================
module vsuart_rx#(
	parameter FIFO_DATA_W = 9
)(
	input                               clk,
	input                               rst_n,
	input                               i_rx_en,
	// fifo
	input                               i_rx_full,
	output [FIFO_DATA_W - 1   : 0]      o_rx_wdata,
	output								o_rx_wen,
	// control
	input                               i_mode_bsel,     // High baud rate Enable bit 
	input   [1  : 0]                    i_mode_pdsel,
	input                               i_mode_spsel,
	input   [15 : 0]                    i_brg,

	// rx side
	input                               i_rx,
	output  							o_sta_frerr,
	output  							o_sta_prerr,
	output                              o_sta_rista,
	output                              o_sta_rbosta
);
// LOCAL VARIABLE HERE---------------------------------------------------
	wire start_det;
	wire sdata;
	wire brg_en;
	wire rx_cken;
	wire frerr_en;
	wire prerr_en;
	wire cnt_en;
	wire shift_right;
	wire rx_data_done;
	wire rx_parity_done;
	wire rx_stop_done;
	wire [4  : 0] rx_st;
// INSTANTIATE MODULE HERE---------------------------------------------------
	// start detection module
	vsuart_rx_start u_vsuart_rx_start (
		.clk            (clk),
		.rst_n          (rst_n),
		.i_rx           (i_rx),
		.o_start_det    (start_det),
		.o_sdata        (sdata)
	);
	// cken generation module
	vsuart_rx_brg u_vsuart_rx_brg (
		.clk            (clk),
		.rst_n          (rst_n),
		// for initial start 
		.i_start_det    (start_det),
		// Enable bit
		.i_brg_en       (brg_en),
		.i_brg          (i_brg),
		// High baud rate Enable bit 
		.i_mode_bsel    (i_mode_bsel),
		.o_rx_cken      (rx_cken)
	);
	// checker module
	vsuart_rx_checker u_vsuart_rx_checker (
		.clk              (clk),
		.rst_n            (rst_n),
		.i_rx_cken        (rx_cken),
		.i_frerr_en       (frerr_en),
		.i_prerr_en       (prerr_en),
		.i_pdata          (o_rx_wdata[7:0]),
		.i_sdata          (sdata),
		// 0: even parity, 1: odd parity
		.i_mode_parity    (i_mode_pdsel[0]),
		.o_sta_frerr      (o_sta_frerr),
		.o_sta_prerr      (o_sta_prerr)
	);
	// bit counter
	bit_cnt u_bit_cnt (
		.clk              (clk),
		.rst_n            (rst_n),
		.i_cken           (rx_cken),
		.i_cnt_en         (cnt_en),
		// Enable bit
		.i_st             (rx_st),
		// state of FSM
		.i_mode_pdsel     (i_mode_pdsel),
		// parity-data select bit
		.i_mode_spsel     (i_mode_spsel),
		// stop bit select bit
		.o_data_done      (rx_data_done),
		.o_parity_done    (rx_parity_done),
		.o_stop_done      (rx_stop_done)
	);
	// shift register
	vsuart_rx_s2p_shifter u_vsuart_rx_s2p_shifter (
		.clk              (clk),
		.i_rx_cken        (rx_cken),
		.i_shift_right    (shift_right),
		.i_mode_pdsel     (i_mode_pdsel),       //-- 'b11: 9-bit data, no parity
												//-- 'b10:  8-bit data, even parity
												//-- 'b01:  8-bit data, odd parity
												//-- 'b00:  8-bit data, no parity
		// serial data
		.i_sdata          (sdata),
		// parallel data
		.o_pdata          (o_rx_wdata)
	);
	// controller
	vsuart_rx_ctrl u_vsuart_rx_ctrl (
		.clk                 (clk),
		.rst_n               (rst_n),
		.i_rx_cken           (rx_cken),
		.i_rx_en             (i_rx_en),
		.i_rx_full           (i_rx_full),
		.i_rx_data_done      (rx_data_done),
		.i_rx_parity_done    (rx_parity_done),
		.i_rx_stop_done      (rx_stop_done),
		.i_mode_pdsel        (i_mode_pdsel),
		.i_sta_frerr         (o_sta_frerr),
		.i_sta_prerr         (o_sta_prerr),
		.o_rx_st             (rx_st),
		.o_frerr_en          (frerr_en),
		.o_prerr_en          (prerr_en),
		.o_cnt_en            (cnt_en),
		.o_rx_wen            (o_rx_wen),
		.o_brg_en            (brg_en),
		.o_shift_right       (shift_right),
		.o_sta_rbosta		 (o_sta_rbosta),
		.o_sta_rista		 (o_sta_rista)
	);
//---------------------------------------------------------------------------

endmodule
