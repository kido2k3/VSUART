//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_rx_checker
//-- History         : ver.1.00 (26/10/8) 1st release
//--                 :
//===========================================================================
module vsuart_rx_checker(
	input 			clk,
	input 			rst_n,
	input 			i_rx_cken,
	input 			i_frerr_en,
	input 			i_prerr_en,
	input 	[7 : 0]	i_pdata,
	input 			i_sdata,
    input           i_mode_parity,     // 0: even parity, 1: odd parity
	output 			o_sta_frerr,
	output			o_sta_prerr
);
// LOCAL VARIABLE HERE-------------------------------------------------------
	reg r_sta_frerr;
	reg r_sta_prerr;
	wire parity;
//---------------------------------------------------------------------------
	// parity generation
    assign parity = (i_mode_parity) ? ~^i_pdata : ^i_pdata;
	// error gen
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_sta_frerr <= 0;
			r_sta_prerr <= 0;
        end else if (i_rx_cken && ~|{i_prerr_en, i_frerr_en}) begin
			r_sta_frerr <= 0;
			r_sta_prerr <= 0;
		end else if (i_rx_cken && i_prerr_en) begin
			r_sta_prerr <= (parity != i_sdata);
		end else if (i_rx_cken && i_frerr_en) begin
			r_sta_frerr <= (i_sdata != 1'b1);
		end
	end
	// output
	assign o_sta_prerr = r_sta_prerr;
	assign o_sta_frerr = r_sta_frerr;
endmodule
//===========================================================================
