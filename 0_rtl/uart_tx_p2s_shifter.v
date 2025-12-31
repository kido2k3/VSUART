//===========================================================================
//-- File Version    : 1.00
//-- Date            : 25/12/27
//-- Author          : kido
//-- IP Name         : uart_tx_p2s_shifter (UART TX parallel to serial shift register)
//-- History         : ver.1.00 (25/12/30) 1st release
//--
//===========================================================================
module uart_tx_p2s_shifter (
    input               clk,
    input   [8 : 0]     i_data,
    input               i_load,            // load parallel data in
    input               i_shift_right,     // shift right control
    output              o_data
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    reg [8 : 0] r_data;
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if (i_load) begin
            r_data  <= i_data;
        end  else if (i_shift_right) begin
            r_data  <= r_data >> 1;
        end
    end
    assign  o_data = r_data[0];
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
endmodule
//===========================================================================