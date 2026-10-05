//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_tx_ctrl (controller)
//-- History         : ver.1.00 (26/10/4)
//===========================================================================
module vsuart_tx_ctrl (
    input               clk,
    input               rst_n,
	input				i_tx_en,
    input               i_tx_cken,
    input               i_tx_empty,
    input               i_tx_data_done,
    input               i_tx_parity_done,
    input               i_tx_stop_done,
	input [1 : 0]		i_mode_pdsel,
    output				o_tx_ren,
	output				o_brg_en,
	output				o_cnt_en,
	output [4 : 0]		o_tx_st,
    output				o_shift_right,     // shift right control
    output				o_sta_trsta,
    output				o_sta_tista,
	// interrupt
	output				o_ifs_txifs0,
	output				o_ifs_txifs1,
	output				o_ifs_txifs2,

);
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg [4  : 0]    r_st_cur;
    reg [4  : 0]    st_nxt;
//---------------------------------------------------------------------------
	// current state
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			r_st_cur <= `IDLE;
		end else if (!i_tx_en) begin
			r_st_cur <= `IDLE;
		end else if (i_tx_cken) begin
			r_st_cur <= st_nxt;
		end
	end
	// next state
    always @(*) begin
		st_nxt = r_st_cur;
        case (r_cur_st)
            `IDLE: begin
				if(i_tx_empty) begin
					st_nxt = `START_BIT;
				end
			end
			`START_BIT: begin
				st_nxt = `DATA;
			end
			`DATA: begin
				if(i_tx_data_done) begin
					if(i_mode_pdsel == 1 || i_mode_pdsel == 2)begin
						st_nxt = `PARITY;
					end else begin
						st_nxt = `STOP;
					end
				end
			end
			`PARITY: begin
				if(i_tx_parity_done) begin
					st_nxt = `STOP;
				end
			end
			`STOP_BIT: begin
				if(i_tx_stop_done) begin
					if(!i_tx_empty) begin
						st_nxt = `START_BIT;
					end else begin
						st_nxt = `IDLE;
					end
				end
			end
        endcase
    end
	// read fifo enable
	assign o_tx_ren = 	(i_tx_cken == 0) ? 0 :
						(r_st_cur == `IDLE && nxt_st == `START_BIT) ? 1 :
						(r_st_cur == `STOP_BIT && nxt_st == `START_BIT) ? 1 : 0;
	// enable brg
	assign o_brg_en = r_st_cur != `IDLE;
	// state of FSM
	assign o_tx_st = r_st_cur;
	// enable count
	assign o_cnt_en = r_st_cur == `DATA || r_st_cur == `PARITY || r_st_cur == `STOP_BIT;
	// shift right in data
	assign o_shift_right = r_st_cur == `DATA;
//---------------------------------------------------------------------------
	assign o_sta_trsta = i_tx_empty && r_st_cur == `IDLE;
	assign o_sta_tista = r_st_cur == `IDLE;
	assign o_ifs_txifs0 = o_tx_ren;
	assign o_ifs_txifs1 = i_tx_empty && r_st_cur == `IDLE;
	assign o_ifs_txifs2 = i_tx_empty && r_st_cur == `START_BIT;
//---------------------------------------------------------------------------
endmodule
//===========================================================================