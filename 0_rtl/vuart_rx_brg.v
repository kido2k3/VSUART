//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/23
//-- Author          : kido
//-- IP Name         : vuart_rx_brg
//-- History         : ver.1.00 (26/5/23) 1st release
//===========================================================================
module vuart_rx_brg (
    input               clk,
    input               rst_n,
    input               i_start,    // Start bit detection 
    input               i_en,       // Enable bit
    input               i_bsel,     // High baud rate Enable bit 
    input   [15 : 0]    i_brg,
    output              o_rx_sample
);
// LOCAL VARIABLE HERE ------------------------------------------------------
    wire    rx_cken;
    reg     [15 : 0] cnt;
    reg     [4 : 0] cnt_tx;
    wire    [4 : 0] over_sampling;
//---------------------------------------------------------------------------
    assign over_sampling = (i_bsel) ? 3 : 15;
//---------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= i_brg;
        end else if(i_en) begin
            if(cnt == 0) begin 
                cnt <= i_brg;
            end else begin
                cnt <= cnt - 1;
            end
        end else begin
            cnt <= i_brg;
        end
    end
    assign rx_cken = 	(i_en) ? (cnt == 0) : 0; 
//---------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_tx <= over_sampling;
        end else if(i_en && rx_cken) begin
            if(cnt_tx == 0) begin 
                cnt_tx <= over_sampling;
            end else begin
                cnt_tx <= cnt_tx - 1;
            end
        end else begin
            cnt_tx <= over_sampling;
        end
    end
    assign o_rx_sample =    (i_bsel && rx_cken) ? (cnt_tx == 5'd2) :
                            (~i_bsel && rx_cken) ? (cnt_tx == 5'd8) : i_start;
//---------------------------------------------------------------------------
endmodule
//===========================================================================