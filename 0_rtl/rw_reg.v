// ============================================================================
//  Module      : rw_reg
//  Description : Read/Write register with APB ↔ UART clock crossing
// ============================================================================
module rw_reg #(
    parameter  DW       = 32,
    parameter  DAT_INI  = {DW{1'b0}}
)(
    // APB clock domain
    input           i_clk,
    input           i_rst,      // active low
    input [31:2]    paddr,      // current APB address
    input [31:2]    waddr,      // register word address
    input [DW-1:0]  pdata,      // write data (already masked)
    input           wen,

    // UART clock domain
    input           o_clk,
    input           o_rst,      // active low

    // Outputs
    output [DW-1:0] o_apb_reg,  // APB shadow register
    output [DW-1:0] o_uart_reg  // UART domain register
);

    // ------------------------------------------------------------
    // APB write detect
    // ------------------------------------------------------------
    wire         hit_addr; 
    reg [DW-1:0] ri_sync_ff1;    
    reg [DW-1:0] ro_apb_reg;
    reg [DW-1:0] ro_uart_reg;
    
    assign hit_addr = (paddr == waddr);

    // ------------------------------------------------------------
    // APB clock domain register
    // ------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            ro_apb_reg <= DAT_INI;
        end
        else if (hit_addr && wen) begin
            ro_apb_reg <= pdata;
        end
    end
    assign o_apb_reg = ro_apb_reg;
    
    // ------------------------------------------------------------
    // Synchronize APB reg into UART clock domain
    // ------------------------------------------------------------
    always @(posedge o_clk or negedge o_rst) begin
        if (!o_rst) begin
            ri_sync_ff1   <= DAT_INI;
            ro_uart_reg   <= DAT_INI;
        end
        else begin
            ri_sync_ff1   <= ro_apb_reg;
            ro_uart_reg   <= ri_sync_ff1;
        end
    end
    assign o_uart_reg = ro_uart_reg;
endmodule
