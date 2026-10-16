//===========================================================================
//-- IP Name         : vsuart_rx_ctrl (rx controller)
//-- Author          : kido
//--                 :
//-- History         : ver.1.00 (26/01/17)
//===========================================================================
module vsuart_rx_ctrl (
	input				clk,
	input				rst_n,
	input				i_rx_cken,
	input				i_rx_en,
	input				i_rx_full,
	input				i_rx_data_done,
	input				i_rx_parity_done,
	input				i_rx_stop_done,
	input [1 : 0]		i_mode_pdsel,
	input				i_sta_frerr,
	input				i_sta_prerr,
	output [4 : 0]		o_rx_st,
	output				o_frerr_en,
	output				o_prerr_en,
	output				o_cnt_en,
	output				o_rx_wen,
	output				o_brg_en,
	output				o_shift_right,
    output				o_sta_rista,
    output				o_sta_rbosta
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg [4  : 0]    r_st_cur;
    reg [4  : 0]    st_nxt;
//---------------------------------------------------------------------------
	// current state
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			r_st_cur <= `IDLE;
		end else if (!i_rx_en) begin
			r_st_cur <= `IDLE;
		end else if (i_rx_cken) begin
			r_st_cur <= st_nxt;
		end
	end
	// next state
    always @(*) begin
		st_nxt = r_st_cur;
        case (r_st_cur)
            `IDLE: begin
				if(!i_rx_full) begin
					st_nxt = `START_BIT;
				end
			end
			`START_BIT: begin
				st_nxt = `DATA;
			end
			`DATA: begin
				if(i_rx_data_done) begin
					if(i_mode_pdsel == 1 || i_mode_pdsel == 2)begin
						st_nxt = `PARITY;
					end else begin
						st_nxt = `STOP;
					end
				end
			end
			`PARITY: begin
				if(i_rx_parity_done) begin
					st_nxt = `STOP;
				end
			end
			`STOP_BIT: begin
				if(i_tx_stop_done) begin
					st_nxt = `IDLE;
				end
			end
			default: st_nxt = r_st_cur;
        endcase
    end
	// FSM state
	assign o_rx_st = r_st_cur;
	// enable parity, frame error check
	assign o_prerr_en = r_st_cur == `PARITY;
	assign o_frerr_en = r_st_cur == `STOP_BIT;
	// enable count
	assign o_cnt_en = r_st_cur == `DATA || r_st_cur == `PARITY || r_st_cur == `STOP_BIT;
	// enable shift right
	assign o_shift_right = r_st_cur == `DATA;
	// enable brg
	assign o_brg_en = r_st_cur != `IDLE;
	// write fifo enable
	assign o_rx_wen = 	(i_rx_cken == 0) ? 0 :
						(r_st_cur == `STOP_BIT && st_nxt == `IDLE && !i_sta_frerr && !i_sta_prerr) ? 1 : 0;
	// 
	assign o_sta_rista = r_st_cur == `IDLE;
	assign o_sta_rbosta = i_rx_full && r_st_cur == `IDLE && i_rx_cken;
endmodule
//===========================================================================