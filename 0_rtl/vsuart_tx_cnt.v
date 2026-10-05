//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_tx_cnt
//-- History         : ver.1.00 (26/10/4) 1st release
//===========================================================================
module vsuart_tx_cnt (
    input               clk,
    input               rst_n,
    input               i_tx_cken, 
    input               i_cnt_en,   	// Enable bit
    input   [4 : 0]		i_tx_st,   		// state of FSM
    input   [1 : 0]     i_mode_pdsel,	// parity-data select bit
	input               i_mode_spsel,	// stop bit select bit
    output              o_tx_data_done,
	output              o_tx_parity_done,
	output              o_tx_stop_done
);
// LOCAL VARIABLE HERE ------------------------------------------------------
    reg     [3 : 0] r_cnt;
	wire	[3 : 0] data_cnt;

//---------------------------------------------------------------------------
	// loading data count
	assign data_cnt = (i_mode_pdsel == 2'b00) ? 4'd7 : 4'd8;
	// counting
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_cnt <= data_cnt;
		end else if(i_cnt_en) begin
			if(i_tx_cken) begin
				if(r_cnt == 0) begin
					if(i_tx_st == `DATA) begin
						r_cnt <= data_cnt;
					end else if(i_tx_st == `PARITY) begin
						r_cnt <= 4'd0;
					end else if(i_tx_st == `STOP_BIT) begin
						r_cnt <= (i_mode_spsel) ? 4'd1 : 4'd0;
					end
				end else begin
					r_cnt <= r_cnt - 1;
				end
			end else begin
				r_cnt <= data_cnt;
			end
		end
	end
//---------------------------------------------------------------------------
	assign o_tx_data_done = (i_tx_st == `DATA) ? (r_cnt == 0) : 1'b0;
	assign o_tx_parity_done = (i_tx_st == `PARITY) ? (r_cnt == 0) : 1'b0;
	assign o_tx_stop_done = (i_tx_st == `STOP_BIT) ? (r_cnt == 0) : 1'b0;
endmodule
//===========================================================================