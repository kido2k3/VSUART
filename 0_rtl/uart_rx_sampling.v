//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/01/09
//-- Author          : kido
//-- IP Name         : uart_rx_sampling
//-- History         : ver.1.00 
//--                 :
//===========================================================================
module uart_rx_sampling(
    input   clk,
    input   rst_n,
    input   i_rx_pulse,
    input   i_rx,
    input   i_reg_brg_hb_en,        // High Baud Rate Enable bit
    input   i_idle_st,              // 1: fsm in idle state
                                    // 0: fsm in other states
    output  o_sdata,
    output  o_sample_en
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    wire    [3      : 0]    sample_id;
    wire    [3      : 0]    end_id;
    reg     [1      : 0]    r_rx;
    wire                    rx_sync;
    reg                     rx_sync_2;
    // start bit detected (in this case, negedge detection)
    wire                    start_bit_dt;
    // counter from 0 to 15
    reg     [3      : 0]    cur_cnt;
    wire    [3      : 0]    nxt_cnt;
//---------------------------------------------------------------------------
    assign sample_id = (i_reg_brg_hb_en) ? 4'd1  : 4'd7;
    assign end_id    = (i_reg_brg_hb_en) ? 4'd3  : 4'd15;
//---------------------------------------------------------------------------
    // 2-FF clock synchronizer
    always @(posedge clk) begin
        r_rx <= {r_rx[0], i_rx};
    end
    assign rx_sync = r_rx[1];
//---------------------------------------------------------------------------
    // determine start bit detected
    always @(posedge clk) begin
        if(i_rx_pulse) begin
            rx_sync_2 <= rx_sync;
        end
    end
    assign start_bit_dt = i_idle_st & (rx_sync_2 & rx_sync);
//---------------------------------------------------------------------------
    // counter controller
    always @(posedge clk) begin
        if(rst_n) begin
            cur_cnt <= 4'd0;
        end else if(i_rx_pulse) begin
            cur_cnt <= nxt_cnt;
        end
    end
    assign nxt_cnt =    (start_bit_dt)      ? 4'd1 :
                        (cur_cnt == end_id) ? 4'd0 : cur_cnt + 1'd1;
//---------------------------------------------------------------------------
    // determine sample enable & serial data
    assign o_sample_en  = (cur_cnt == sample_id);
    assign o_sdata      = (o_sample_en) ? rx_sync : 1'b1;
//---------------------------------------------------------------------------
endmodule
//===========================================================================
