//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/23
//-- Author          : kido
//-- IP Name         : vsuart apb slave
//-- History         : ver.1.00 (26/5/23) 1st release
//--                 :
//===========================================================================
module vsuart_apb_slv #(
    parameter P_ADDR_W          = 16,
    parameter P_DATA_W          = 32,
    parameter P_FIFO_DATA_W     = 9,
    // do not replace following parameters
    parameter P_STRB_W          = P_DATA_W / 8,
    parameter P_REG_ADDR_W      = P_ADDR_W - 2
) (
    // GLOBAL RESET
    input                       rst_n,
    // APB INTERFACE
    input                               pclk,
    input                               preset_n,
    input   [P_ADDR_W - 1 : 0]          i_paddr,
    input                               i_psel,
    input                               i_penable,
    input                               i_pwrite,
    input   [P_DATA_W - 1 : 0]          i_pwdata,
    input   [P_STRB_W - 1 : 0]          i_pstrb,
    output                              o_pready,
    output  [P_DATA_W - 1 : 0]          o_prdata,
    output                              o_pslverr,
    // REGISTER SIDE
    output  [P_REG_ADDR_W - 1 : 0]      o_reg_addr,
    output  [P_DATA_W - 1 : 0]          o_reg_wdata,
    output  [P_DATA_W - 1 : 0]          o_reg_wmask,
    output                              o_reg_wen, // 1: write, 0: read
    input   [P_DATA_W - 1 : 0]          i_reg_rdata,
    input                               i_reg_ready, 
    input                               i_reg_slverr,
    // UART SIDE
    input                               i_tx_ready, 
    input                               i_rx_ready, 
    output  [P_FIFO_DATA_W - 1  : 0]    o_tx_wdata,
    output                              o_tx_wren,
    input   [P_FIFO_DATA_W - 1  : 0]    i_rx_rdata,
    output                              o_rx_rden
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
    `include "vsuart_define.v"
//---------------------------------------------------------------------------
    // VARIABLE
    wire                            ready;
    // decoded register address 
    wire    [P_REG_ADDR_W - 1 : 0]  reg_addr;
    // check address of data: 16'hFFFF
    wire    data_addr;
    // for mask generation from strb
    wire    [P_DATA_W - 1   : 0]    strb_mask;
    // for mask generation from addr
    reg     [P_DATA_W - 1   : 0]    addr_mask;
//---------------------------------------------------------------------------
    // REGISTER SIDE
    // address 
    assign reg_addr = i_paddr[P_ADDR_W - 1 : 2];
    // mask generation
    generate
        genvar id;
        for (id = 0; id < P_STRB_W; id = id + 1) begin
            assign strb_mask[id*8 +: 8] = (i_pstrb[id]) ? 8'hFF : 0;
        end
    endgenerate
    
    always @(*) begin
        case (reg_addr)
            `ADDR_UART_MODE: addr_mask = `UART_MODE_MASK;
            `ADDR_UART_CR: addr_mask = `UART_CR_MASK;
            `ADDR_UART_STA: addr_mask = `UART_STA_MASK;
            `ADDR_UART_PRS: addr_mask = `UART_PRS_MASK;
            `ADDR_UART_BRG: addr_mask = `UART_BRG_MASK;
            `ADDR_UART_IE: addr_mask = `UART_IE_MASK;
            `ADDR_UART_IFS: addr_mask = `UART_IFS_MASK;
            `ADDR_UART_IFC: addr_mask = `UART_IFC_MASK;
            default: addr_mask = 0;
        endcase
    end
    // output
    assign o_reg_wmask = addr_mask & strb_mask;
    assign o_reg_wdata = i_pwdata;
    assign o_reg_wen = i_pwrite & i_penable & i_psel & ready;
    assign o_reg_addr = reg_addr;
//---------------------------------------------------------------------------
    // UART SIDE
    // address for data access 16'hFFFF
    assign data_addr = &i_paddr;
    
    // tx
    assign o_tx_wdata = i_pwdata;
    assign o_tx_wren = data_addr & i_pwrite & i_penable & i_psel & ready;

    // rx
    assign o_rx_rden = data_addr & ~i_pwrite & i_penable & i_psel & ready;
//---------------------------------------------------------------------------
    // APB SIDE
    assign ready = i_reg_ready & i_tx_ready & i_rx_ready;
    assign o_pready = ready;
    assign o_prdata = (data_addr) ? i_rx_rdata : i_reg_rdata;
    assign o_pslverr = i_reg_slverr;
//---------------------------------------------------------------------------
endmodule