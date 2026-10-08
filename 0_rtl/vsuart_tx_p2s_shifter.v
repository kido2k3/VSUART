//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_tx_p2s_shifter (UART TX parallel to serial shift register)
//-- History         : ver.1.00 (25/12/27)
//--                 :
//===========================================================================
module vsuart_tx_p2s_shifter #(
    parameter           DATA_W    = 9
)(
    input                           clk,
    input                           i_tx_cken,
    input   [DATA_W - 1   : 0]    i_data,
    input                           i_load,            // load parallel data in
    input                           i_shift_right,     // shift right control
    output                          o_data
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg [DATA_W - 1 : 0] r_data;
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if(i_tx_cken) begin
            if (i_load) begin
                r_data  <= i_data;
            end  else if (i_shift_right) begin
                r_data  <= r_data >> 1;
            end
        end
    end
    assign  o_data = r_data[0];
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================