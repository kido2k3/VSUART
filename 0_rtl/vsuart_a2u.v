//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_a2u (apb to uart synchronizer)
//-- History         : ver.1.00 (26/10/3)
//===========================================================================
module vsuart_a2u #(
    parameter FIFO_DEPTH = 32,
    parameter FIFO_DATA_W = 9
)(
    // global reset
    input                               rst_n,
    // apb side
    input                               pclk,
    input [2 : 0]                       i_mode_uen,
    input                               i_tx_wen,
    input [FIFO_DATA_W - 1  : 0]        i_tx_wdata,
    output                              o_tx_ready,
    output                              o_sta_tbsta,
    output                              o_rx_ready,
    // tx side
    input                               u_clk, 
    output                              o_tx_en,
    input                               i_tx_ren,
    output                              o_tx_empty,
    output [FIFO_DATA_W - 1   :0]       o_tx_rdata,
    output                              o_ifs_txifs3,
    // rx side
    output                              o_rx_en
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    wire tx_en;
    wire rx_en;
//---------------------------------------------------------------------------
    // tx enable
    assign tx_en = i_mode_uen[0] & i_mode_uen[2];
    cdc_unit_hs u_tx_sync (
        // WRITE SIDE
        .w_clk        (pclk),
        .w_rst_n      (rst_n),
        .i_w_data     (tx_en),
        .o_w_ready    (o_tx_ready),
        // READ SIDE
        .r_clk        (u_clk),
        .r_rst_n      (rst_n),
        .o_r_data     (o_tx_en)
    );

    // rx enable
    assign rx_en = i_mode_uen[1] & i_mode_uen[2];
    cdc_unit_hs u_rx_sync (
        // WRITE SIDE
        .w_clk        (pclk),
        .w_rst_n      (rst_n),
        .i_w_data     (rx_en),
        .o_w_ready    (o_rx_ready),
        // READ SIDE
        .r_clk        (u_clk),
        .r_rst_n      (rst_n),
        .o_r_data     (o_rx_en)
    );
    
    // tx fifo
    a_fifo #(
        .P_DEPTH      (FIFO_DEPTH),
        .P_DATA_W     (FIFO_DATA_W)
    ) u_tx_fifo (
        // WRITE INTERFACE: i_ (input), w_ (write)
        .w_clk        (pclk),
        .w_rst_n      (rst_n),
        .i_w_en       (i_tx_wen),
        .i_w_data     (i_tx_wdata),
        .o_w_full     (o_sta_tbsta),
        // READ INTERFACE
        .r_clk        (u_clk),
        .r_rst_n      (rst_n),
        .i_r_en       (i_tx_ren),
        .o_r_empty    (o_tx_empty),
        .o_r_data     (o_tx_rdata)
    );
//---------------------------------------------------------------------------
    assign o_ifs_txifs3 = o_sta_tbsta & i_tx_wen;
endmodule
//===========================================================================