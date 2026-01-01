//===========================================================================
//-- File Version    : 1.00
//-- Date            : 25/12/31
//-- Author          : kido
//-- IP Name         : uart_tx_parity_gen (UART TX parity generator)
//-- History         : ver.1.00 (25/12/31)
//--                 :
//===========================================================================
module uart_tx_parity_gen #(
    parameter           P_DATA_W    = 9
)(
    input                           clk,
    input   [P_DATA_W - 1   : 0]    i_data,
    input                           i_en,              // enable signal
    input                           i_mode_parity,     // 0: even parity, 1: odd parity
    output                          o_data
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg r_data;
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if (i_en) begin
            r_data  <= (i_mode_parity) ? ~^i_data[7: 0] : ^i_data[7: 0];
        end
    end
    assign  o_data = r_data;
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================