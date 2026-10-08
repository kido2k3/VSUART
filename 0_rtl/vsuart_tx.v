//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_tx
//-- History         : ver.1.00 (26/10/3)
//===========================================================================
module vsuart_tx #(
	parameter FIFO_DATA_W = 9
)(
	input                               clk,
	input                               rst_n,
	// fifo
	input                               i_tx_en,
	input                               i_tx_empty,
	input [FIFO_DATA_W - 1   : 0]       i_tx_rdata,
	output								o_tx_ren,
	// register
	input                               i_mode_bsel,
	input [1 : 0]                       i_mode_pdsel,
	input                               i_mode_spsel,
	output                              o_sta_trsta,
	output                              o_sta_tista,
	input [15 : 0]                      i_brg_brg,
	// interrupt
	output								o_ifs_txifs0,
	output								o_ifs_txifs1,
	output								o_ifs_txifs2,
	// uart
	output                              o_tx
);
// LOCAL VARIABLE HERE-------------------------------------------------------
	wire brg_en;
	wire cnt_en;
	wire tx_cken;
	wire shift_right;
	wire [4 : 0] tx_st;
	wire tx_data_done;
	wire tx_parity_done;
	wire tx_stop_done;
	wire data;
	wire parity;
// INSTANTIATE MODULE HERE---------------------------------------------------
	vsuart_tx_brg u_vsuart_tx_brg (
		.clk            (clk),
		.rst_n          (rst_n),
		.i_tx_empty     (i_tx_empty),
		// for initial start 
		.i_brg_en       (brg_en),
		// Enable bit
		.i_brg          (i_brg_brg),
		.i_mode_bsel    (i_mode_bsel),
		// High baud rate Enable bit 
		.o_tx_cken      (tx_cken)
	);

	vsuart_tx_cnt u_vsuart_tx_cnt (
		.clk                 (clk),
		.rst_n               (rst_n),
		.i_tx_cken           (tx_cken),
		// Enable bit
		.i_cnt_en            (cnt_en),
		// state of FSM
		.i_tx_st             (tx_st),
		// parity-data select bit
		.i_mode_pdsel        (i_mode_pdsel),
		// stop bit select bit
		.i_mode_spsel        (i_mode_spsel),
		.o_tx_data_done      (tx_data_done),
		.o_tx_parity_done    (tx_parity_done),
		.o_tx_stop_done      (tx_stop_done)
	);

	vsuart_tx_gen #(
		.i_tx_st     (tx_st),
		.i_data      (data),
		.i_parity    (parity),
		.o_tx        (o_tx)
	);

	vsuart_tx_ctrl u_vsuart_tx_ctrl (
		.clk                 (clk),
		.rst_n               (rst_n),
		.i_tx_en             (i_tx_en),
		.i_tx_cken           (tx_cken),
		.i_tx_empty          (i_tx_empty),
		.i_tx_data_done      (tx_data_done),
		.i_tx_parity_done    (tx_parity_done),
		.i_tx_stop_done      (tx_stop_done),
		.i_mode_pdsel        (i_mode_pdsel),
		.o_tx_ren            (o_tx_ren),
		.o_brg_en            (brg_en),
		.o_cnt_en            (cnt_en),
		.o_tx_st             (tx_st),
		// shift right control
		.o_shift_right       (shift_right),
		.o_sta_trsta		 (o_sta_trsta),
		.o_sta_tista		 (o_sta_tista),
		// interrupt
		.o_ifs_txifs0		 (o_ifs_txifs0),
		.o_ifs_txifs1		 (o_ifs_txifs1),
		.o_ifs_txifs2		 (o_ifs_txifs2)

	);

	vsuart_tx_parity #(
		.DATA_W         (FIFO_DATA_W)
	) u_vsuart_tx_parity (
		.clk              (clk),
		.i_data           (i_tx_rdata),
		// enable signal
		.i_en             (o_tx_ren),
		// 0: even parity, 1: odd parity
		.i_mode_parity    (i_mode_pdsel[0]),
		.o_data           (parity)
	);

	vsuart_tx_p2s_shifter #(
		.DATA_W         (FIFO_DATA_W)
	) u_vsuart_tx_p2s_shifter (
		.clk              (clk),
		.i_tx_cken        (tx_cken),
		.i_data           (i_tx_rdata),
		.i_load           (o_tx_ren),
		// load parallel data in
		.i_shift_right    (shift_right),
		// shift right control
		.o_data           (data)
	);
//---------------------------------------------------------------------------
endmodule
//===========================================================================