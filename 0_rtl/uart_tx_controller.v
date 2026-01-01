//===========================================================================
//-- File Version    : 1.00
//-- Date            : 25/12/31
//-- Author          : kido
//-- IP Name         : uart_tx_controller
//-- History         : ver.1.00 (25/12/31)
//--                 :
//===========================================================================
module uart_tx_controller (
    input               clk,
    input               rst_n,
    input               i_tx_en,
    input               i_tx_pulse,
    input               i_fifo_empty,
    input               i_tx_brk,
    input  [1 : 0]      i_mode_pdata,           //-- 'b11: 9-bit data, no parity
                                                //-- 'b10: 8-bit data, even parity
                                                //-- 'b01:  8-bit data, odd parity
                                                //-- 'b00:  8-bit data, no parity
    output              o_fifo_rd_en,           //-- fifo read enable
    output              o_srt_st,               //-- 1: busy, 0: empty
    output              o_srt_shift_right,      //-- 1: busy, 0: empty
    output [1 : 0]      o_sel                   //-- 0: idle, 1: start/stop bit, 2: serial data, 3: parity bit
);
// FSM STATE HERE------------------------------------------------------------
    localparam  P_IDLE          = 3'd0;
    localparam  P_START_BIT     = 3'd1;
    localparam  P_DATA_FRAME    = 3'd2;
    localparam  P_PARITY_BIT    = 3'd3;
    localparam  P_STOP_BIT      = 3'd4;
    localparam  P_BREAK_TRANS   = 3'd5;
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg [2  : 0]    cur_st;
    reg [2  : 0]    nxt_st;
//---------------------------------------------------------------------------
    // output of FSM
    reg             fifo_rd_en;
    reg [1  : 0]    sel;
    reg             shifter_busy;
    reg             right_shift;
    reg             tx_brk_done;
    reg             cnt_up;
    reg             cnt_rst_n;
    // counter
    reg     [3 : 0] cur_cnt;
    wire    [3 : 0] nxt_cnt;
//---------------------------------------------------------------------------
    // determine next state, and output
    always @(*) begin
        nxt_st          = P_IDLE;
        fifo_rd_en      = 0;
        sel             = 0;
        shifter_busy    = 0;
        right_shift     = 0;
        tx_brk_done     = 0;
        cnt_up          = 0;
        cnt_rst_n       = 1;
        if (i_tx_en) begin
            if(!i_tx_pulse) begin
                nxt_st = cur_st;
            end else begin
                nxt_st = cur_st;
                case (cur_st)
                    P_IDLE: begin
                        if(!i_fifo_empty || i_tx_brk) begin
                            nxt_st          = P_START_BIT;
                            fifo_rd_en      = 1'b1;
                            shifter_busy    = 1'b1;
                            sel             = 2'd1;
                        end
                    end
                    P_START_BIT:begin
                        if(!i_tx_brk) begin
                            nxt_st          = P_DATA_FRAME;
                            sel             = 2'd2;
                            shifter_busy    = 1'b1;
                            cnt_rst_n       = 1'b0;
                        end else begin
                            nxt_st          = P_BREAK_TRANS;
                            cnt_rst_n       = 1'b0;
                        end
                    end
                    P_DATA_FRAME:begin
                        if(cur_cnt < 4'd8 || cur_cnt == 4'd8 && i_mode_pdata == 2'b11) begin
                            nxt_st          = P_DATA_FRAME;
                            sel             = 2'd2;
                            shifter_busy    = 1'b1;
                            cnt_up          = 1'b1;
                        end else if (^i_mode_pdata && cur_cnt == 4'd8) begin
                            nxt_st          = P_PARITY_BIT;
                            sel             = 2'd3;
                        end else if(&i_mode_pdata && cur_cnt == 4'd9 || ~|i_mode_pdata && cur_cnt == 4'd8) begin
                            nxt_st          = P_STOP_BIT;
                            sel             = 2'd1;
                            cnt_rst_n       = 1'b0;
                        end
                    end
                    P_PARITY_BIT:begin
                        nxt_st          = P_STOP_BIT;
                        sel             = 2'd1;
                        cnt_rst_n       = 1'b0;
                    end
                    P_STOP_BIT:begin
                        if(cur_cnt < 4'd2 && i_mode_pdata) begin
                            nxt_st      = P_STOP_BIT;
                            sel         = 4'd1;
                            cnt_up      = 1'b1;
                        end else if(cur_cnt == 4'd1 && !i_mode_pdata || cur_cnt == 4'd2 || i_tx_brk) begin
                            nxt_st      = P_IDLE;
                            tx_brk_done = 1'b1;
                            sel         = 1'b0;
                        end
                    end
                    P_BREAK_TRANS:begin
                        if(cur_cnt < 4'd12) begin
                            nxt_st      = P_BREAK_TRANS;
                            sel         = 2'd1;
                            cnt_up      = 1'b1;
                        end else if(cur_cnt == 4'd12) begin
                            nxt_st      = P_STOP_BIT;
                            sel         = 2'd1;
                        end
                    end
                endcase
            end
        end
    end
    // determine next counter
    assign nxt_cnt =    (!i_tx_en)      ? 4'd0 :
                        (!i_tx_pulse)   ? cur_cnt :
                        (!cnt_rst_n)    ? 4'd0 :
                        (cnt_up)        ? cur_cnt + 1'd1 : cur_cnt;
    // determine current register
    always @(posedge clk) begin
        if(!rst_n) begin
            cur_cnt     <= 4'd0;
            cur_st      <= P_IDLE;
        end else begin
            cur_cnt     <= nxt_cnt;
            cur_st      <= nxt_st;
        end
    end
//---------------------------------------------------------------------------
    // determine output
    assign o_fifo_rd_en         = fifo_rd_en;   
    assign o_srt_st             = shifter_busy;       
    assign o_sel                = sel;
    assign o_srt_shift_right    = right_shift;
//---------------------------------------------------------------------------
endmodule
//===========================================================================