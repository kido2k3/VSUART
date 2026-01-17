// Decode address
localparam [29:0] p_reg_uart_en      = (32'h0000_0000 >> 2);
localparam [29:0] p_reg_uart_csr     = (32'h0000_0004 >> 2);
localparam [29:0] p_reg_uart_sta     = (32'h0000_0008 >> 2);
localparam [29:0] p_reg_uart_mode    = (32'h0000_000c >> 2);
localparam [29:0] p_reg_uart_brg     = (32'h0000_0010 >> 2);
localparam [29:0] p_reg_uart_ie      = (32'h0000_0014 >> 2);
localparam [29:0] p_reg_uart_if      = (32'h0000_0018 >> 2);
localparam [29:0] p_reg_uart_ifclr   = (32'h0000_001c >> 2);

// Initial value
localparam [31:0] p_reg_uart_en_ini    = 32'h0000_0000;
localparam [31:0] p_reg_uart_csr_ini   = 32'h0000_0000;
localparam [31:0] p_reg_uart_sta_ini   = 32'h0000_0000;
localparam [31:0] p_reg_uart_mode_ini  = 32'h0000_0000;
localparam [31:0] p_reg_uart_brg_ini   = 32'h0000_0000;
localparam [31:0] p_reg_uart_ie_ini    = 32'h0000_0000;
localparam [31:0] p_reg_uart_if_ini    = 32'h0000_0000;
localparam [31:0] p_reg_uart_ifclr_ini = 32'h0000_0000;

module apb2reg (
    input         uart_clk,
    input         rst_n,
    input         pclk,
    input         presetn,
    
    // Register outputs (from APB side to register logic)
    input  [31:0] i_reg_addr,
    input         i_reg_wr,
    input         i_reg_rd,
    input  [31:0] i_reg_wr_data,
    input         i_reg_err_ack,

    // Register side (from register logic back to APB side)
    output [3 :0] o_reg_rd_wait,
    output [31:0] o_reg_rd_data,
    output        o_reg_ack,
    output        o_reg_err,

    // Register control signals
    output        reg_uart_en,
    output [31:0] reg_uart_csr,
    output [31:0] reg_uart_sta,
    output [31:0] reg_uart_mode,
    output [31:0] reg_uart_brg,
    output [31:0] reg_uart_ie,
    output [31:0] reg_uart_if,
    output [31:0] reg_uart_ifclr
);

    // ------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------
    wire [31:0] val_wr_data;
    wire [31:0] mod_wr_data;
    wire [31:0] raw_rd_data;

    // APB side shadow registers
    wire [31:0] apb_reg_uart_en;
    wire [31:0] apb_reg_uart_csr;
    wire [31:0] apb_reg_uart_sta;
    wire [31:0] apb_reg_uart_mode;
    wire [31:0] apb_reg_uart_brg;
    wire [31:0] apb_reg_uart_ie;
    wire [31:0] apb_reg_uart_if;
    wire [31:0] apb_reg_uart_ifclr;
    
    reg  [31:0] r_reg_uart_en;
    reg  [31:0] r_reg_uart_csr;
    reg  [31:0] r_reg_uart_sta;
    reg  [31:0] r_reg_uart_mode;
    reg  [31:0] r_reg_uart_brg;
    reg  [31:0] r_reg_uart_ie;
    reg  [31:0] r_reg_uart_if;
    reg  [31:0] r_reg_uart_ifclr;

    // ------------------------------------------------------------
    // Write mask by address
    // ------------------------------------------------------------
    assign val_wr_data =(i_reg_addr[31:2] == p_reg_uart_en   ) ? 32'h0000_0001 : // bit0
                        (i_reg_addr[31:2] == p_reg_uart_csr  ) ? 32'h0000_003F : // bit0-5
                        (i_reg_addr[31:2] == p_reg_uart_sta  ) ? 32'h0000_0001 :
                        (i_reg_addr[31:2] == p_reg_uart_mode ) ? 32'h0000_000F : // bit0-3
                        (i_reg_addr[31:2] == p_reg_uart_brg  ) ? 32'h0000_FFFF : // bit0-15
                        (i_reg_addr[31:2] == p_reg_uart_ie   ) ? 32'h0000_0007 : // bit0-2
                        (i_reg_addr[31:2] == p_reg_uart_if   ) ? 32'h0000_0007 :
                        (i_reg_addr[31:2] == p_reg_uart_ifclr) ? 32'h0000_0007 :
                        32'h0000_0000;

    assign mod_wr_data = i_reg_wr_data & val_wr_data;

    // ------------------------------------------------------------
    // RW registers
    // ------------------------------------------------------------
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_en_ini))    u_uart_en    (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_en   ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_en   ), .o_uart_reg(r_reg_uart_en));
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_csr_ini))   u_uart_csr   (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_csr  ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_csr  ), .o_uart_reg(r_reg_uart_csr));
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_sta_ini))   u_uart_sta   (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_sta  ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_sta  ), .o_uart_reg(r_reg_uart_sta));
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_mode_ini))  u_uart_mode  (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_mode ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_mode ), .o_uart_reg(r_reg_uart_mode));    
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_brg_ini))   u_uart_brg   (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_brg  ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_brg  ), .o_uart_reg(r_reg_uart_brg));    
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_ie_ini))    u_uart_ie    (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_ie   ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_ie   ), .o_uart_reg(r_reg_uart_ie));    
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_if_ini))    u_uart_if    (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_if   ), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_if   ), .o_uart_reg(r_reg_uart_if));    
    rw_reg #(.DW(32), .DAT_INI(p_reg_uart_ifclr_ini)) u_uart_ifclr (.i_clk(pclk), .i_rst(presetn), .o_clk(uart_clk), .o_rst(rst_n), .wen(i_reg_wr), .paddr(i_reg_addr[31:2]), .waddr(p_reg_uart_ifclr), .pdata(mod_wr_data), .o_apb_reg(apb_reg_uart_ifclr), .o_uart_reg(r_reg_uart_ifclr));
    // ------------------------------------------------------------
    // APB read mux
    // ------------------------------------------------------------
    assign raw_rd_data =  (i_reg_addr[31:2] == p_reg_uart_en   ) ? apb_reg_uart_en   :
                          (i_reg_addr[31:2] == p_reg_uart_csr  ) ? apb_reg_uart_csr  :
                          (i_reg_addr[31:2] == p_reg_uart_sta  ) ? apb_reg_uart_sta  :
                          (i_reg_addr[31:2] == p_reg_uart_mode ) ? apb_reg_uart_mode :
                          (i_reg_addr[31:2] == p_reg_uart_brg  ) ? apb_reg_uart_brg  :
                          (i_reg_addr[31:2] == p_reg_uart_ie   ) ? apb_reg_uart_ie   :
                          (i_reg_addr[31:2] == p_reg_uart_if   ) ? apb_reg_uart_if   :
                          (i_reg_addr[31:2] == p_reg_uart_ifclr) ? apb_reg_uart_ifclr:
                          32'h0000_0000;
    // ------------------------------------------------------------
    // APB handshake (More details will be added later)
    // ------------------------------------------------------------    
    assign in_access     = i_reg_wr | i_reg_rd;
    assign o_reg_rd_wait = 4'h0;
    assign o_reg_ack     = i_reg_wr | i_reg_rd;                          // logic will be added latter
    assign o_reg_err     = (raw_rd_data == 32'h0000_0000 && in_access) ? 1'b1 :       //Error: read address not hit
                           (val_wr_data == 32'h0000_0000 && in_access) ? 1'b1 : 1'b0; //Error: write address not hit                                         
    assign o_reg_rd_data = i_reg_rd ? raw_rd_data : 32'h0000_0000; 
    // ------------------------------------------------------------
    // Output register
    // ------------------------------------------------------------
    assign reg_uart_en     = r_reg_uart_en;
    assign reg_uart_csr    = r_reg_uart_csr;
    assign reg_uart_sta    = r_reg_uart_sta;
    assign reg_uart_mode   = r_reg_uart_mode;
    assign reg_uart_brg    = r_reg_uart_brg;
    assign reg_uart_ie     = r_reg_uart_ie;
    assign reg_uart_if     = r_reg_uart_if;
    assign reg_uart_ifclr  = r_reg_uart_ifclr;

endmodule
