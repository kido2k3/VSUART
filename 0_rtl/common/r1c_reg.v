//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/24
//-- Author          : kido
//-- IP Name         : r1c_reg (read 1 to clear register model)
//-- History         : ver.1.00 (26/5/24) 1st release
//--                 :
//===========================================================================

module r1c_reg #(
    parameter ADDR_W            = 14,
    parameter DATA_W            = 32,
    parameter ADDR              = 14'h0,
    parameter MASK              = 32'h0, // internal mask
    parameter MASK_CLR          = 32'h0, // internal mask to clear
    parameter POR_VAL           = 32'h0 
) (
    input                               clk,
    input                               rst_n,
    // INTERNAL USE: write via mask
    input   [DATA_W - 1         : 0]    i_wdata, 
    input   [DATA_W - 1         : 0]    i_wmask, // for internal use
    // USER USE
    input   [ADDR_W - 1         : 0]    i_addr_clr,
    input                               i_ren_clr, // 1: read, 0: reserved
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
        end else if (i_addr == ADDR && i_ren_clr) begin
            // user clear
            mem_r <= (MASK_CLR & {DATA_W{1'b0}}) | (~MASK_CLR & mem_r);
        end else begin
            // internal write
            mem_r <= (mask & i_wdata) | (~mask & mem_r);
        end
    end

    // register read
    assign o_rdata = mem_r;
//---------------------------------------------------------------------------

endmodule