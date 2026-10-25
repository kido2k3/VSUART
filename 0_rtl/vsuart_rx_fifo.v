//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_rx_fifo
//-- History         : ver.1.00 (26/10/8) 1st release
//--                 :
//===========================================================================
module vsuart_rx_fifo #(
    parameter P_DEPTH       = 8, 
    parameter P_DATA_W      = 8
)(
    // WRITE INTERFACE (uart)
    input                               wclk, 
    input                               wrst_n, 
    input                               w_en, 
    input           [P_DATA_W - 1   :0] i_data,
    output                              o_full,
    // READ INTERFACE (apb)
    input                               rclk, 
    input                               rrst_n, 
    input                               r_en,
    output          [2              :0] o_r_ifs,
    output                              o_empty,
    output          [P_DATA_W - 1   :0] o_data
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
    localparam  P_PTR_W = $clog2(P_DEPTH) + 1; // log2(P_DEPTH) + 1
    //localparam  P_PTR_W = 4; // log2(P_DEPTH) + 1
    localparam DEPTH_075 = P_DEPTH * 3 / 4; 
//---------------------------------------------------------------------------
    // VARIABLE
    wire [P_PTR_W - 1 : 0] g_wptr_sync;
    wire [P_PTR_W - 1 : 0] g_rptr_sync;
    // binary write pointer to fifo, not used empty, full bit
    wire [P_PTR_W - 2 : 0] b_wptr; 
    // binary read pointer to fifo, not used empty, full bit
    wire [P_PTR_W - 2 : 0] b_rptr;
    wire [P_PTR_W - 1 : 0] g_wptr; 
    wire [P_PTR_W - 1 : 0] g_rptr;
    // binary of read pointer in apb domain
    wire [P_PTR_W - 1 : 0] b_rptr_sync;
    // counter for finding 3/4
    wire [P_PTR_W - 1 : 0] cnt;
    wire not_less_075;
//---------------------------------------------------------------------------
    genvar i;
    // convert gray read pointer to bin in apb domain
    generate
        for(i=0; i<P_PTR_W; i=i+1) begin
            assign b_rptr_sync[i] = ^(g_rptr_sync >> i);
        end
    endgenerate
    // counter
    // the remaining charater in fifo is [P_PTR_W - 2 : 0]
    // fifo full when [P_PTR_W - 1] = 1 and [P_PTR_W - 2 : 0] = 0
    assign cnt = b_wptr - b_rptr_sync;
    // not less than 3/4
    assign not_less_075 =   (cnt[P_PTR_W - 1] && ~|cnt[P_PTR_W - 2 : 0]) ? 1'b1 :
                            cnt[P_PTR_W - 2 : 0] >= DEPTH_075[P_PTR_W - 2 : 0];
    assign o_r_ifs[0] = !o_empty;
    assign o_r_ifs[1] = not_less_075;
    assign o_r_ifs[2] = cnt[P_PTR_W - 1] && ~|cnt[P_PTR_W - 2 : 0];
//---------------------------------------------------------------------------
    //write pointer to read clock domain
    synchronizer #(
        .P_DATA_W    (P_PTR_W)
    ) u_synchronizer0 (
        .clk         (rclk),
        .rst_n       (rrst_n),
        .i_data      (g_wptr),
        .o_data      (g_wptr_sync)
    );
    //read pointer to write clock domain
    synchronizer #(
        .P_DATA_W    (P_PTR_W)
    ) u_synchronizer1 (
        .clk         (wclk),
        .rst_n       (wrst_n),
        .i_data      (g_rptr),
        .o_data      (g_rptr_sync)
    );
//---------------------------------------------------------------------------
    wptr_handler #(
        .P_PTR_W          (P_PTR_W)
    ) u_wptr_handler (
        .wclk             (wclk),
        .wrst_n           (wrst_n),
        .i_w_en           (w_en),
        .i_g_rptr_sync    (g_rptr_sync),
        .o_b_wptr         (b_wptr),
        .o_g_wptr         (g_wptr),
        .o_full           (o_full)
    );
    rptr_handler #(
        .P_PTR_W          (P_PTR_W)
    ) u_rptr_handler (
        .rclk             (rclk),
        .rrst_n           (rrst_n),
        .i_r_en           (r_en),
        .i_g_wptr_sync    (g_wptr_sync),
        .o_b_rptr         (b_rptr),
        .o_g_rptr         (g_rptr),
        .o_empty          (o_empty)
    );
//---------------------------------------------------------------------------
    fifo_mem #(
        .P_DEPTH     (P_DEPTH),
        .P_DATA_W    (P_DATA_W)
    ) u_fifo_mem (
        // WRITE INTERFACE
        .wclk        (wclk),
        .w_en        (w_en),
        .b_wptr      (b_wptr),
        .i_data      (i_data),
        .i_full      (o_full),
        // READ INTERFACE
        .b_rptr      (b_rptr),
        .o_data      (o_data)
    );
//---------------------------------------------------------------------------

endmodule
//===========================================================================
