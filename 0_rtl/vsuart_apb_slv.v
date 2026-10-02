//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/23
//-- Author          : kido
//-- IP Name         : vsuart apb slave
//-- History         : ver.1.00 (26/5/23) 1st release
//--                 :
//===========================================================================
module vsuart_apb_slv #(
    parameter ADDR_W            = 16,
    parameter DATA_W            = 32,
    parameter FIFO_DATA_W       = 9,
    // do not replace following parameters
    parameter STRB_W            = DATA_W / 8,
    parameter REG_ADDR_W        = ADDR_W - 2
) (
    // GLOBAL RESET
    input                               rst_n,
    // APB INTERFACE
    input                               preset_n,
    input   [ADDR_W - 1 : 0]            i_paddr,
    input                               i_psel,
    input                               i_penable,
    input                               i_pwrite,
    input   [DATA_W - 1 : 0]            i_pwdata,
    input   [STRB_W - 1 : 0]            i_pstrb,
    output                              o_pready,
    output  [DATA_W - 1 : 0]            o_prdata,
    output                              o_pslverr,
    // REGISTER SIDE
    output  [REG_ADDR_W - 1 : 0]        o_reg_addr,
    output  [DATA_W - 1 : 0]            o_reg_wdata,
    output  [DATA_W - 1 : 0]            o_reg_wmask,
    output                              o_reg_wen, // 1: write, 0: read
    input   [DATA_W - 1 : 0]            i_reg_rdata,
    input                               i_reg_ready, 
    input                               i_reg_slverr,
    // UART SIDE
    input                               i_tx_ready, 
    input                               i_rx_ready, 
    input                               i_rx_empty, 
    output  [FIFO_DATA_W - 1  : 0]      o_tx_wdata,
    output                              o_tx_wren,
    input   [FIFO_DATA_W - 1  : 0]      i_rx_rdata,
    output                              o_rx_rden
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
    wire                            _rst_n;
    // decoded register address 
    wire    [REG_ADDR_W - 1 : 0]  reg_addr;
    // check address of data: 16'hFFFF
    wire    data_addr;
    // for mask generation from strb
    wire    [DATA_W - 1   : 0]    strb_mask;
    // for mask generation from addr
    reg     [DATA_W - 1   : 0]    addr_mask;
    // for generation
    genvar id;
//---------------------------------------------------------------------------
    // REGISTER SIDE
    // reset
    assign _rst_n = rst_n & preset_n;
    // address 
    assign reg_addr = i_paddr[ADDR_W - 1 : 2];
    // mask generation
    generate
        for (id = 0; id < STRB_W; id = id + 1) begin
            assign strb_mask[id*8 +: 8] = (i_pstrb[id]) ? 8'hFF : 0;
        end
    endgenerate
    // output
    assign o_reg_wmask = (~_rst_n) ? 0 : strb_mask;
    assign o_reg_wdata = (~_rst_n) ? 0 : i_pwdata;
    assign o_reg_wen = i_pwrite & i_penable & i_psel & o_pready & _rst_n;
    assign o_reg_addr = (~_rst_n) ? 0 : reg_addr;
//---------------------------------------------------------------------------
    // UART SIDE
    // address for data access 16'hFFFF
    assign data_addr = &i_paddr;
    
    // tx
    assign o_tx_wdata = i_pwdata;
    assign o_tx_wren = data_addr & i_pwrite & i_penable & i_psel & o_pready & _rst_n;

    // rx
    assign o_rx_rden = data_addr & ~i_pwrite & i_penable & i_psel & o_pready & _rst_n;
//---------------------------------------------------------------------------
    // APB SIDE
    assign o_pready = ~_rst_n | (i_reg_ready & i_tx_ready & i_rx_ready);
    assign o_prdata = (~_rst_n) ? 0 : (data_addr) ? i_rx_rdata : i_reg_rdata;
    assign o_pslverr = (~_rst_n) ? 0 : 
        (data_addr) ? (~i_pwrite & i_penable & i_psel & i_rx_empty) : i_reg_slverr;
//---------------------------------------------------------------------------
endmodule