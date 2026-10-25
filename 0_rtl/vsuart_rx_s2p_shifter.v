//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_rx_s2p_shifter (serial to parallel shift register)
//-- History         : ver.1.00 (26/10/8) 1st release
//--                 :
//===========================================================================
module vsuart_rx_s2p_shifter(
	input               clk,
	input               i_rx_cken,
	input               i_shift_right,
	input   [1  : 0]    i_mode_pdsel,   //-- 'b11: 9-bit data, no parity
										//-- 'b10:  8-bit data, even parity
										//-- 'b01:  8-bit data, odd parity
										//-- 'b00:  8-bit data, no parity
	input               i_sdata,        // serial data
	output  [8  : 0]    o_pdata         // parallel data
);
// LOCAL VARIABLE HERE-------------------------------------------------------
	reg     [8  : 0]    r_data;
//---------------------------------------------------------------------------
	always @(posedge clk) begin
		if(i_shift_right && i_rx_cken) begin
			r_data  <= {i_sdata, r_data[8 : 1]};
		end
	end
//---------------------------------------------------------------------------
	assign o_pdata  = (&i_mode_pdsel) ? r_data : {1'b0, r_data[8 : 1]};
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================
