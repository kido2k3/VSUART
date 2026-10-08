//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/24
//-- Author          : kido
//-- IP Name         : wr_reg (write register model)
//-- History         : ver.1.00 (26/5/24) 1st release
//--                 :
//===========================================================================

module wr_reg #(
    parameter ADDR_W            = 14,
    parameter DATA_W            = 32,
    parameter ADDR              = 14'h0,
    parameter MASK              = 32'h0, // internal mask
    parameter POR_VAL           = 32'h0 
) (
    input                               clk,
    input                               rst_n,
    input   [ADDR_W - 1         : 0]    i_addr,
    input                               i_wen, // 1: write, 0: reserved
    input   [DATA_W - 1         : 0]    i_wdata,
    input   [DATA_W - 1         : 0]    i_wmask, // mask from user
    output  [DATA_W - 1         : 0]    o_rdata
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
    reg [DATA_W - 1: 0] mem_r;
    wire [DATA_W - 1: 0] mask;
//---------------------------------------------------------------------------
    // mask gen
    assign mask = i_wmask & MASK;

    // register write
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            mem_r <= POR_VAL;
        end else if (i_addr == ADDR && i_wen) begin
            mem_r <= (mask & i_wdata) | (~mask & mem_r);
        end
    end

    // register read
    assign o_rdata = mem_r;
//---------------------------------------------------------------------------

endmodule