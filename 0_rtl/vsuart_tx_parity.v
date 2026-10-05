//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_tx_parity
//-- History         : ver.1.00 (26/10/4) 1st release
//===========================================================================
module vsuart_tx_parity #(
    parameter           DATA_W    = 9
)(
    input                           clk,
    input   [DATA_W - 1   : 0]    i_data,
    input                           i_en,              // enable signal
    input                           i_mode_parity,     // 0: even parity, 1: odd parity
    output                          o_data
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg r_data;
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if (i_en) begin
            r_data  <= (i_mode_parity) ? ~^i_data[DATA_W - 2: 0] : ^i_data[DATA_W - 2: 0];
        end
    end
    assign  o_data = r_data;
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================