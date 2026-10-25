//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_rx_start (start bit detector)
//-- History         : ver.1.00 (26/01/09)
//--                 :
//===========================================================================
module vsuart_rx_start(
	input   	clk,
	input   	rst_n,
	input   	i_rx,
	output		o_start_det,
	output		o_sdata
);
// LOCAL VARIABLE HERE-------------------------------------------------------
	wire	rx_sync;
//---------------------------------------------------------------------------
	cdc_unit u_cdc_unit (
		.clk         (clk),
		.rst_n       (rst_n),
		.i_data      (i_rx),
		.o_data      (rx_sync)
	);
	edge_det #(
		.MODE      (0)
    // 0: negedge detect; 1: posedge detect
	) u_edge_det (
		.clk       (clk),
		.rst_n     (rst_n),
		.i_data    (rx_sync),
		.o_data    (o_start_det)
	);
//---------------------------------------------------------------------------
	// serital data
	assign o_sdata = rx_sync;
//---------------------------------------------------------------------------
endmodule
//===========================================================================
