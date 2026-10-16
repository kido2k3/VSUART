//===========================================================================
//-- Author          : kido
//-- Name            : edge_det (edge detector)
//-- History         : ver.1.00 (26/10/08) 1st release
//--                 :
//===========================================================================
module edge_det #(
    parameter MODE            = 1                   // 0: negedge detect; 1: posedge detect
)(
    input                             clk,
    input                             rst_n,
    input                             i_data,
    output                            o_data
);
//------------------------------------------------------------------------
    // LOCALPARAM HERE
//------------------------------------------------------------------------
    // VARIABLE HERE
    reg r_data;
//------------------------------------------------------------------------
    always @(posedge clk) begin
        r_data <= i_data;
    end
    generate
        if(MODE == 0) begin
            assign o_data = (!rst_n) ? 1'b0 : ~i_data & r_data;
        end else begin
            assign o_data = (!rst_n) ? 1'b0 : i_data & ~r_data;
        end
    endgenerate
endmodule