//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/01/10
//-- Author          : kido
//-- IP Name         : uart_rx_fifo
//-- History         : ver.1.00 (26/01/10): determine status of fifo
//--                 :
//===========================================================================
module uart_rx_fifo #(
    parameter                           P_DATA_W    = 8,
    parameter                           P_DEPTH     = 8
)(
    input                               clk, 
    input                               rst_n, 
    input       [P_DATA_W - 1   : 0]    i_data,
    input                               i_wr_en,
    input                               i_rd_en,
    output      [2              : 0]    o_fifo_st,  //-- fifo status 
                                                    //-- bit 0: fifo empty
                                                    //-- bit 1: fifo 3/4 full
                                                    //-- bit 2: fifo full
    output                              o_full,
    output      [P_DATA_W - 1   : 0]    o_data
);
// LOCAL PARAMETER HERE------------------------------------------------------
    localparam P_CNT_W  = $clog2(P_DEPTH - 1);
// LOCAL VARIABLE HERE-------------------------------------------------------
    wire                        empty;
    wire                        full;
    wire [P_CNT_W - 1    : 0]   cnt;
//---------------------------------------------------------------------------
    syn_fifo #(
        .P_DATA_W    (P_DATA_W),
        .P_DEPTH     (P_DEPTH)
    ) u_syn_fifo (
        .clk         (clk),
        .rst_n       (rst_n),
        .i_data      (i_data),
        .i_wr_en     (i_wr_en),
        .i_rd_en     (i_rd_en),
        .o_cnt       (cnt),
        .o_full      (full),
        .o_empty     (empty),
        .o_data      (o_data)
    );
//---------------------------------------------------------------------------
    // determine fifo status
    assign o_fifo_st[0] = empty;
    assign o_fifo_st[1] = (cnt == ((P_DEPTH >> 2) * 3));
    assign o_fifo_st[2] = full;
//---------------------------------------------------------------------------
endmodule
//===========================================================================