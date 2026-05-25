//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/5/23
//-- Author          : kido
//-- IP Name         : a_fifo (Asynchronous FIFO)
//-- History         : ver.1.00 (26/5/23) 1st release
//--                 :
//===========================================================================
module a_fifo #(
    parameter P_DEPTH       = 8, 
    parameter P_DATA_W      = 8
)(
    // WRITE INTERFACE: i_ (input), w_ (write)
    input                               w_clk, 
    input                               w_rst_n, 
    input                               i_w_en, 
    input           [P_DATA_W - 1   :0] i_w_data,
    output                              o_w_full,
    // READ INTERFACE
    input                               r_clk, 
    input                               r_rst_n, 
    input                               i_r_en,
    output                              o_r_empty,
    output  reg     [P_DATA_W - 1   :0] o_r_data
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
    // P_PTR_W: 1 bit extra to diff empty and full
    localparam  P_PTR_W = $clog2(P_DEPTH) + 1; 
    //localparam  P_PTR_W = 4; // log2(P_DEPTH) + 1
//---------------------------------------------------------------------------
    // VARIABLE
    // status
    reg     w_full_r;
    wire    w_full_nxt;
    reg     w_empty_r;
    wire    w_empty_nxt;
    // fifo memory
    reg [P_DATA_W - 1   : 0] fifo_mem [P_DEPTH];
    // pointer (binary): _r (register), _g (gray)
    reg     [P_PTR_W - 1    : 0] w_ptr_r;
    reg     [P_PTR_W - 1    : 0] r_ptr_r;
    reg     [P_PTR_W - 1    : 0] w_ptr_g_r;
    reg     [P_PTR_W - 1    : 0] r_ptr_g_r;
    // next pointer (binary)
    wire    [P_PTR_W - 1    : 0] w_ptr_nxt;
    wire    [P_PTR_W - 1    : 0] r_ptr_nxt;
    wire    [P_PTR_W - 1    : 0] w_ptr_g_nxt;
    wire    [P_PTR_W - 1    : 0] r_ptr_g_nxt;
    // synchronized signals
    reg     [P_PTR_W - 1    : 0] w_ptr_g_r1;
    reg     [P_PTR_W - 1    : 0] w_ptr_g_r2;
    reg     [P_PTR_W - 1    : 0] r_ptr_g_r1;
    reg     [P_PTR_W - 1    : 0] r_ptr_g_r2;
//---------------------------------------------------------------------------
    // WRITE POINTER HANDLER
    // control w_ptr, w_ptr, w_full
    always @(posedge w_clk or negedge w_rst_n) begin
        if(!w_rst_n) begin
            w_ptr_r <= 0;
            w_ptr_g_r <= 0;
            w_full_r <= 0;
        end else begin
            w_ptr_r <= w_ptr_nxt;
            w_ptr_g_r <= w_ptr_g_nxt;
            w_full_r <= w_full_nxt;
        end
    end
    // estimate next value
    assign w_ptr_nxt = w_ptr_r + (!w_full && i_w_en);
    assign w_ptr_g_nxt = w_ptr_nxt ^ (w_ptr_nxt >> 1);
    assign w_full_nxt = (w_ptr_nxt == {~r_ptr_r2[P_PTR_W - 1 -: 2], r_ptr_r2[0 +: P_PTR_W - 2]});
//---------------------------------------------------------------------------
    // WRITE POINTER SYNC in r_clk domain
    always @(posedge r_clk or negedge r_rst_n) begin
        if(!r_rst_n) begin
            w_ptr_g_r1 <= 0;
            w_ptr_g_r2 <= 0;
        end else begin
            w_ptr_g_r1 <= w_ptr_g_r;
            w_ptr_g_r2 <= w_ptr_g_r1;
        end
    end
//---------------------------------------------------------------------------
    // READ POINTER HANDLER
    // control r_ptr, r_ptr, r_empty
    always @(posedge r_clk or negedge r_rst_n) begin
        if(!r_rst_n) begin
            r_ptr_r <= 0;
            r_ptr_g_r <= 0;
            r_empty_r <= 0;
        end else begin
            r_ptr_r <= r_ptr_nxt;
            r_ptr_g_r <= r_ptr_g_nxt;
            r_empty_r <= r_empty_nxt;
        end
    end
    // estimate next value
    assign r_ptr_nxt = r_ptr_r + (!r_empty && i_r_en);
    assign r_ptr_g_nxt = r_ptr_nxt ^ (r_ptr_nxt >> 1);
    assign r_empty_nxt = (r_ptr_g_nxt == w_ptr_g_r2);
//---------------------------------------------------------------------------
    // READ POINTER SYNC in w_clk domain
    always @(posedge w_clk or negedge w_rst_n) begin
        if(!w_rst_n) begin
            r_ptr_g_r1 <= 0;
            r_ptr_g_r2 <= 0;
        end else begin
            r_ptr_g_r1 <= r_ptr_g_r;
            r_ptr_g_r2 <= r_ptr_g_r1;
        end
    end
//---------------------------------------------------------------------------
    // FIFO MEMORY
    // write side
    always @(posedge w_clk) begin
        if(i_w_en && !w_full_r) begin
            fifo_mem[w_ptr_r[P_PTR_W - 2 : 0]] <= i_w_data;
        end
    end
    assign o_r_data = fifo_mem[r_ptr_r[P_PTR_W - 2 : 0]];
//---------------------------------------------------------------------------
    // ASSIGN OUTPUT
    assign o_w_full = w_full_r;
    assign o_r_empty = r_empty_r;
endmodule
//===========================================================================