//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_rx_brg
//-- History         : ver.1.00 (26/10/8) 1st release
//===========================================================================
module vsuart_rx_brg (
    input               clk,
    input               rst_n,
    input               i_start_det, // for initial start 
    input               i_brg_en,    // Enable bit
    input   [15 : 0]    i_brg,
    input               i_mode_bsel,     // High baud rate Enable bit 
    output              o_rx_cken
);
// LOCAL VARIABLE HERE ------------------------------------------------------
    reg     [15 : 0] r_cnt;
    reg     [3 : 0] r_cnt_tx;
    wire    [3 : 0] over_sampling;
//---------------------------------------------------------------------------
    assign over_sampling = (i_mode_bsel) ? 3 : 15;
//---------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_cnt <= i_brg;
        end else if(i_brg_en) begin
            if(r_cnt == 0) begin 
                r_cnt <= i_brg;
            end else begin
                r_cnt <= r_cnt - 1;
            end
        end else begin
            r_cnt <= i_brg;
        end
    end
//---------------------------------------------------------------------------
    // for tx_cken
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_cnt_tx <= over_sampling/2;
        end else if(i_brg_en) begin
            if(r_cnt == 0) begin
                if(r_cnt_tx == 0) begin 
                    r_cnt_tx <= over_sampling;
                end else begin
                    r_cnt_tx <= r_cnt_tx - 1;
                end
            end
        end else begin
            r_cnt_tx <= over_sampling/2;
        end
    end
    assign o_rx_cken =  (i_brg_en) ? (r_cnt_tx == 0 && r_cnt == 0) : i_start_det;
endmodule
//===========================================================================