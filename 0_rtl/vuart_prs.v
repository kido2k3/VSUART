//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/30
//-- Author          : kido
//-- IP Name         : vuart_prs (prescaler)
//-- History         : ver.1.00 (26/5/30) 1st release
//===========================================================================
module vuart_prs (
    input               clk,
    input               rst_n,
    input               i_en,
    input   [3 : 0]     i_brg,
    output              o_
);
// LOCAL VARIABLE HERE ------------------------------------------------------
    wire    rx_cken,
    reg     [15 : 0] cnt;
    reg     [4 : 0] cnt_tx;
    wire    [4 : 0] over_sampling;
//---------------------------------------------------------------------------
    assign over_sampling = (i_bsel) ? 3 : 15;
//---------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
        end else if(i_en) begin
            if(cnt == 0) begin 
                cnt <= i_brg;
            end else begin
                cnt <= cnt - 1;
            end
        end else begin
            cnt <= 0;
        end
    end
    assign rx_cken = (i_en) ? (cnt == 0) : 1'd0; 
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================