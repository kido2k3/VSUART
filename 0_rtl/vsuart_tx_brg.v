//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_tx_brg
//-- History         : ver.1.00 (26/5/23) 1st release
//===========================================================================
module vsuart_tx_brg (
    input               clk,
    input               rst_n,
    input               i_tx_empty, // for initial start 
    input               i_brg_en,    // Enable bit
    input   [15 : 0]    i_brg,
    input               i_mode_bsel,     // High baud rate Enable bit 
    output              o_tx_cken
);
// LOCAL VARIABLE HERE ------------------------------------------------------
    reg     [15 : 0] r_cnt;
    reg     [3 : 0] r_cnt_tx;
    wire    [3 : 0] over_sampling;
    wire    rx_cken;
//---------------------------------------------------------------------------
    assign over_sampling = (i_mode_bsel) ? 3 : 15;
//---------------------------------------------------------------------------
    // for rx_cken
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
    assign rx_cken = (i_brg_en) ? (r_cnt == 0) : 0;
//---------------------------------------------------------------------------
    // for tx_cken
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_cnt_tx <= over_sampling;
        end else if(i_brg_en) begin
            if(rx_cken) begin
                if(r_cnt_tx == 0) begin 
                    r_cnt_tx <= over_sampling;
                end else begin
                    r_cnt_tx <= r_cnt_tx - 1;
                end
            end
        end else begin
            r_cnt_tx <= over_sampling;
        end
    end
    assign o_tx_cken =  (i_brg_en) ? (r_cnt_tx == 0 && rx_cken) : ~i_tx_empty;
endmodule
//===========================================================================