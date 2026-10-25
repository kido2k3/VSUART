//===========================================================================
//-- Author          : kido
//-- IP Name         : rptr_handler  (read pointer handle)
//-- History         : ver.1.00 (25/11/24) 1st release
//--
//===========================================================================
module rptr_handler #(
    parameter P_PTR_W = 4
)(
    input                               rclk, 
    input                               rrst_n, 
    input                               i_r_en, 
    input       [P_PTR_W - 1    : 0]    i_g_wptr_sync, 
    output  reg [P_PTR_W - 2    : 0]    o_b_rptr,
    output  reg [P_PTR_W - 1    : 0]    o_g_rptr,
    output  reg                         o_empty
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
    reg  [P_PTR_W - 1 : 0] r_b_rptr;
    wire [P_PTR_W - 1 : 0] b_rptr_nxt;
    wire [P_PTR_W - 1 : 0] g_rptr_nxt;
    wire                  empty_nxt;
//---------------------------------------------------------------------------
    assign b_rptr_nxt = r_b_rptr + {{(P_PTR_W-1){1'b0}},(i_r_en && !o_empty)};
    assign g_rptr_nxt = (b_rptr_nxt >>1) ^ b_rptr_nxt;
//---------------------------------------------------------------------------
    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n) begin
            r_b_rptr <= 0; // set default value
            o_g_rptr <= 0;
            o_empty  <= 1;
        end else begin
            r_b_rptr <= b_rptr_nxt;
            o_g_rptr <= g_rptr_nxt;
            o_empty  <= empty_nxt;
        end
    end
//---------------------------------------------------------------------------
    assign empty_nxt = (i_g_wptr_sync == g_rptr_nxt);
    assign o_b_rptr = r_b_rptr[P_PTR_W-2:0];
//---------------------------------------------------------------------------
endmodule
//===========================================================================
