//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_sync_u2a (uart to apb synchronizer)
//-- History         : ver.1.00 (26/10/3)
//===========================================================================
module vsuart_sync_u2a #(
	parameter FIFO_DEPTH = 32,
	parameter FIFO_DATA_W = 9
)(
	// global reset
	input                               rst_n,
	// tx side
	input								u_clk,
	input								i_ifs_txifs0,
	input								i_ifs_txifs1,
	input								i_ifs_txifs2, 
	input								i_ifs_txifs3, 
	input								i_sta_trsta,
	input								i_sta_tista,
	// rx side
	input								i_rx_wen,
	input 	[FIFO_DATA_W - 1  : 0]      i_rx_wdata,
	output								o_rx_full,
	input  								i_sta_frerr,
	input  								i_sta_prerr,
	input  								i_sta_rista,
	input  								i_sta_rbosta,
	// apb side
	input                               pclk,
	input                               i_rx_ren,
	input	[1 : 0] 					i_cr_txisel,
	input	[1 : 0] 					i_cr_rxisel,
	output	[FIFO_DATA_W - 1  : 0]      o_rx_rdata,
	output								o_sta_rbdsta,
	// cdc
	output								o_ifs_errifs,
	output								o_ifs_txifs,
	output								o_ifs_rxifs,
	output								o_ifs_errifs,
	output								o_sta_trsta,
	output								o_sta_tista,
	output  							o_sta_frerr,
	output  							o_sta_prerr,
	output  							o_sta_rista,
	output  							o_sta_rbosta
);
// LOCAL VARIABLE HERE-------------------------------------------------------
	wire ifs_txifs0;
	wire ifs_txifs1;
	wire ifs_txifs2;
	wire [2 : 0] ifs_rxifs;
	wire sta_frerr;
	wire sta_prerr;
	wire sta_rbosta;
	// posedge wire 
	wire pos_ifs_txifs0;
	wire pos_ifs_txifs1;
	wire pos_ifs_txifs2; 
	wire pos_ifs_txifs3; 
	wire pos_ifs_rxifs0;
	wire pos_ifs_rxifs1;
	wire pos_ifs_rxifs2; 
//---------------------------------------------------------------------------
	// edge_det start
	edge_det #(.MODE(1)) u_ifs_txifs0(.clk(pclk), .rst_n(rst_n), .i_data(ifs_txifs0), .o_data(pos_ifs_txifs0));
	edge_det #(.MODE(1)) u_ifs_txifs1(.clk(pclk), .rst_n(rst_n), .i_data(ifs_txifs1), .o_data(pos_ifs_txifs1));
	edge_det #(.MODE(1)) u_ifs_txifs2(.clk(pclk), .rst_n(rst_n), .i_data(ifs_txifs2), .o_data(pos_ifs_txifs2));
	edge_det #(.MODE(1)) u_ifs_txifs3(.clk(pclk), .rst_n(rst_n), .i_data(i_ifs_txifs3), .o_data(pos_ifs_txifs3));
	edge_det #(.MODE(1)) u_ifs_rxifs0(.clk(pclk), .rst_n(rst_n), .i_data(ifs_rxifs[0]), .o_data(pos_ifs_rxifs0));
	edge_det #(.MODE(1)) u_ifs_rxifs1(.clk(pclk), .rst_n(rst_n), .i_data(ifs_rxifs[1]), .o_data(pos_ifs_rxifs1));
	edge_det #(.MODE(1)) u_ifs_rxifs2(.clk(pclk), .rst_n(rst_n), .i_data(ifs_rxifs[2]), .o_data(pos_ifs_rxifs2));
	edge_det #(.MODE(1)) u_sta_frerr(.clk(pclk), .rst_n(rst_n), .i_data(sta_frerr), .o_data(o_sta_frerr));
	edge_det #(.MODE(1)) u_sta_prerr(.clk(pclk), .rst_n(rst_n), .i_data(sta_prerr), .o_data(o_sta_prerr));
	edge_det #(.MODE(1)) u_sta_rbosta(.clk(pclk), .rst_n(rst_n), .i_data(sta_rbosta), .o_data(o_sta_rbosta));
	// edge_det end
	// cdc unit start
	cdc_unit ifs_errifs_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_ifs_errifs), .o_data(o_ifs_errifs));
	cdc_unit ifs_txifs0_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_ifs_txifs0), .o_data(ifs_txifs0));
	cdc_unit ifs_txifs1_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_ifs_txifs1), .o_data(ifs_txifs1));
	cdc_unit ifs_txifs2_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_ifs_txifs2), .o_data(ifs_txifs2));
	cdc_unit sta_trsta_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_sta_trsta), .o_data(o_sta_trsta));
	cdc_unit sta_tista_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_sta_tista), .o_data(o_sta_tista));
	cdc_unit sta_prerr_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_sta_frerr), .o_data(sta_frerr));
	cdc_unit sta_prerr_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_sta_prerr), .o_data(sta_prerr));
	cdc_unit sta_rista_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_sta_rista), .o_data(o_sta_rista));
	cdc_unit sta_rbosta_cdc(.clk(pclk), .rst_n(rst_n), .i_data(i_sta_rbosta), .o_data(sta_rbosta));
	// cdc unit end
	
	// tx interrupt 
	assign o_ifs_txifs = 	(i_cr_txisel == 2'd0) ? pos_ifs_txifs0 :
							(i_cr_txisel == 2'd1) ? pos_ifs_txifs1 :
							(i_cr_txisel == 2'd2) ? pos_ifs_txifs2 : pos_ifs_txifs3;

	// rx interrupt 
	assign o_ifs_rxifs = 	(i_cr_txisel[1] == 1'd0) ? pos_ifs_rxifs0 :
							(i_cr_txisel[0] == 1'd0) ? pos_ifs_rxifs1 : pos_ifs_rxifs2;

	// error interrupt
	assign o_ifs_errifs = o_sta_frerr | o_sta_prerr; 
	// rx fifo
	vsuart_rx_fifo #(
		.FIFO_DEPTH     (FIFO_DEPTH),
		.FIFO_DATA_W    (FIFO_DATA_W)
	) u_vsuart_rx_fifo (
		// WRITE INTERFACE: i_ (input), w_ (write)
		.w_clk          (u_clk),
		.w_rst_n        (rst_n),
		.i_w_en         (i_rx_wen),
		.i_w_data       (i_rx_wdata),
		.o_w_full       (o_rx_full),
		// READ INTERFACE (APB SIDE)
		.r_clk          (pclk),
		.r_rst_n        (rst_n),
		.i_r_en         (i_rx_ren),
		.o_r_ifs        (ifs_rxifs),
		.o_r_empty      (o_sta_rbdsta),
		.o_r_data       (o_rx_rdata)
	);
//---------------------------------------------------------------------------
endmodule
//===========================================================================