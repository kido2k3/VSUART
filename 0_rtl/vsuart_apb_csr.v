//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/24
//-- Author          : kido
//-- IP Name         : vsuart_apb_csr (control-status registers)
//-- History         : ver.1.00 (26/5/24) 1st release
//--                 :
//===========================================================================
module vsuart_apb_csr #(
    parameter P_REG_ADDR_W      = 14,
    parameter P_REG_NUM         = 8,
    parameter P_DATA_W          = 32
) (
    input                               clk,
    input                               rst_n,
    // APB SLAVE SIDE
    input   [P_REG_ADDR_W - 1   : 0]    i_reg_addr,
    input   [P_DATA_W - 1       : 0]    i_reg_wdata,
    input   [P_DATA_W - 1       : 0]    i_reg_wmask,
    input                               i_reg_wen, // 1: write, 0: read
    output  [P_DATA_W - 1       : 0]    o_reg_rdata,
    output                              o_reg_ready, 
    output                              o_reg_slverr,
    // UART SIDE
    output                              o_tx_en,
    output                              o_rx_en,
    output                              o_prs_en,
    output                              o_bsel,
    output  [1                  : 0]    o_pdsel,
    output                              o_spsel,
    output  [1                  : 0]    o_tx_isel,
    output  [1                  : 0]    o_rx_isel,
    input   [2                  : 0]    i_tx_sta,
    input   [4                  : 0]    i_rx_sta,
    output  [3                  : 0]    o_prs,
    output  [15                 : 0]    o_brg,
    // INTERRUPT SIDE
    output  [2                  : 0]    o_ie,
    output  [2                  : 0]    o_ifs
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
    `include "vsuart_define.v"
//---------------------------------------------------------------------------
    // VARIABLE
    reg     [P_DATA_W - 1       : 0]    mem [P_REG_NUM];
    wire    [P_DATA_W - 1       : 0]    wdata [P_REG_NUM];
    wire    [P_DATA_W - 1       : 0]    init_val [P_REG_NUM];
    genvar i;
//---------------------------------------------------------------------------
    // REG control
    // initial value
    assign init_val[`ADDR_UART_MODE] = `POR_UART_MODE;
    assign init_val[`ADDR_UART_CR]   = `POR_UART_CR;
    assign init_val[`ADDR_UART_STA]  = `POR_UART_STA;
    assign init_val[`ADDR_UART_PRS]  = `POR_UART_PRS;
    assign init_val[`ADDR_UART_BRG]  = `POR_UART_BRG;
    assign init_val[`ADDR_UART_IE]   = `POR_UART_IE;
    assign init_val[`ADDR_UART_IFS]  = `POR_UART_IFS;
    assign init_val[`ADDR_UART_IFC]  = `POR_UART_IFC;
    // next value of register
    generate
        for (i = 0; i < P_REG_NUM; i = i + 1) begin
            if(i == `ADDR_UART_STA) begin
                assign wdata[i] =   (i_reg_wen && i_reg_addr == `ADDR_UART_STA) ? (i_reg_wmask & i_reg_wdata) | (~i_reg_wmask & mem[i]) :
                                    (~i_reg_wen && i_reg_addr == `ADDR_UART_STA) ? (32'h18 & mem[i]) : {i_rx_sta , i_tx_sta};
            end else if(i == `ADDR_UART_IFS) begin
                assign wdata[i] =   (i_reg_wen && i_reg_addr == `ADDR_UART_IFC) ? mem[i] & ~i_reg_wdata : mem[i];
            end if(i == `ADDR_UART_IFC) begin
                assign wdata[i] =   (i_reg_wen && i_reg_addr == `ADDR_UART_IFC) ? (i_reg_wmask & i_reg_wdata) | (~i_reg_wmask & mem[i]) :`POR_UART_IFC;
            end else begin
                assign wdata[i] = (i_reg_wen && i_reg_addr == i) ? (i_reg_wmask & i_reg_wdata) | (~i_reg_wmask & mem[i]) : mem[i];
            end
        end
    endgenerate
    // register
    generate
        for (i = 0; i < P_REG_NUM; i = i + 1) begin
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    mem[i] <= init_val[i];
                end else begin
                    mem[i] <= wdata[i];
                end
            end
        end
    endgenerate
//---------------------------------------------------------------------------
    // UART MODE
    // output
    assign o_tx_en = mem[`ADDR_UART_MODE][0] & mem[`ADDR_UART_MODE][2];
    assign o_rx_en = mem[`ADDR_UART_MODE][1] & mem[`ADDR_UART_MODE][2];
    assign o_prs_en = mem[`ADDR_UART_MODE][2];
    assign o_bsel = mem[`ADDR_UART_MODE][8];
    assign o_pdsel = mem[`ADDR_UART_MODE][17:16];
    assign o_spsel = mem[`ADDR_UART_MODE][24];
//---------------------------------------------------------------------------
    // UART CR
    // output
    assign o_tx_isel = mem[`ADDR_UART_CR][1:0];
    assign o_rx_isel = mem[`ADDR_UART_CR][9:8];
//---------------------------------------------------------------------------
    // UART PRS, BRG
    // output
    assign o_prs = mem[`ADDR_UART_PRS][3:0];
    assign o_brg = mem[`ADDR_UART_BRG][15:0];
//---------------------------------------------------------------------------
    // INTERRUPT SIDE
    assign o_ie = {mem[`ADDR_UART_IE][16], mem[`ADDR_UART_IE][8], mem[`ADDR_UART_IE][0]};
    assign o_ifs = {mem[`ADDR_UART_IFS][16], mem[`ADDR_UART_IFS][8], mem[`ADDR_UART_IFS][0]};
//---------------------------------------------------------------------------
endmodule