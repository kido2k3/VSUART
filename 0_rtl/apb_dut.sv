// ============================================================================
//  Module      : apb_dut
//  Description : APB4-compliant module that instances apb_mem.
//                Retains original port list, with unused master ports driven to default.
//
//  Author      : hungdt110520@gmail.com
//  Date        : 2025-07-21
// ============================================================================

module apb_dut (
    input  logic         pclk,       // APB clock (from top)
    input  logic         presetn,    // APB resetn (from top)
    input  logic         uart_clk,   // UART clock (from top)
    input  logic         rst_n,      // UART resetn (from top)

    // APB4 Slave Interface (from APB master in testbench)
    input  logic         s_pwrite,
    input  logic         s_psel,
    input  logic         s_penable,
    input  logic [31:0]  s_paddr,
    input  logic [31:0]  s_pwdata,
    input  logic [3:0]   s_pstrb,
    input  logic [2:0]   s_pprot, // unused by apb_mem

    output logic         s_pready,
    output logic         s_pslverr,
    output logic [31:0]  s_prdata,

    // APB4 Master Interface (to APB slave in testbench, now unused)
    output logic         m_pwrite,
    output logic         m_psel,
    output logic         m_penable,
    output logic [31:0]  m_paddr,
    output logic [31:0]  m_pwdata,
    output logic [3:0]   m_pstrb,
    output logic [2:0]   m_pprot,
    input  logic         m_pready,  // Unused by apb_mem
    input  logic         m_pslverr, // Unused by apb_mem
    input  logic [31:0]  m_prdata,  // Unused by apb_mem
    
    // Register control signals
    output logic         reg_uart_en,
    output logic [31:0]  reg_uart_csr,
    output logic [31:0]  reg_uart_sta,
    output logic [31:0]  reg_uart_mode,
    output logic [31:0]  reg_uart_brg,
    output logic [31:0]  reg_uart_ie,
    output logic [31:0]  reg_uart_if,
    output logic [31:0]  reg_uart_ifclr
    );

    // Drive unused master outputs to default values
    assign m_pwrite   = 1'b0;
    assign m_psel     = 1'b0;
    assign m_penable  = 1'b0;
    assign m_paddr    = 32'b0;
    assign m_pwdata   = 32'b0;
    assign m_pstrb    = 4'b0;
    assign m_pprot    = 3'b0;
    
    logic [3:0]   reg_rd_wait;
    logic [31:0]  reg_rd_data;
    logic         reg_ack;
    logic         reg_err;

    logic [31:0]  reg_addr;
    logic         reg_wr;
    logic         reg_rd;
    logic [31:0]  reg_wr_data;
    logic         reg_err_ack;

    // Instance of apb_mem
    // Connect apb_dut's slave interface to apb_mem's interface
    /*apb_mem i_apb_mem (
        .PCLK   (pclk),
        .PRESETn(presetn),
        .PSEL   (s_psel),
        .PENABLE(s_penable),
        .PWRITE (s_pwrite),
        .PADDR(s_paddr),
        .PWDATA(s_pwdata),
        .PSTRB(s_pstrb),
        .PPROT(s_pprot),
        .PREADY(s_pready),
        .PRDATA(s_prdata),
        .PSLVERR(s_pslverr)
    );
    */
    apb_slave #(
        .p_use_ack (1'h0),
        .p_wr_wait (4'h0),
        .p_rd_wait (4'h1)
    ) u_apb_slave (
        // APB side
        .i_pclk        (pclk),
        .i_preset      (presetn),
        .i_paddr       (s_paddr),
        .i_pprot       (s_pprot),
        .i_psel        (s_psel),
        .i_penable     (s_penable),
        .i_pwrite      (s_pwrite),
        .i_pwdata      (s_pwdata),
        .i_pstrb       (s_pstrb),

        // Register side
        .i_reg_rd_wait (reg_rd_wait),
        .i_reg_rd_data (reg_rd_data),
        .i_reg_ack     (reg_ack),
        .i_reg_err     (reg_err),


        // To APB outputs
        .o_pready      (s_pready),
        .o_prdata      (s_prdata),
        .o_pslverr     (s_pslverr),

        // To register outputs
        .o_reg_addr    (reg_addr),
        .o_reg_wr      (reg_wr),
        .o_reg_rd      (reg_rd),
        .o_reg_wr_data (reg_wr_data),
        .o_reg_err_ack (reg_err_ack)
    );
    
    apb2reg u_apb2reg(
        .uart_clk      (uart_clk ),
        .rst_n         (rst_n    ),
        .pclk          (pclk     ),
        .presetn       (presetn  ),
        
        // Register outputs
        .i_reg_addr    (reg_addr),
        .i_reg_wr      (reg_wr),
        .i_reg_rd      (reg_rd),
        .i_reg_wr_data (reg_wr_data),
        .i_reg_err_ack (reg_err_ack),  //to clear err flag
        
        // Register side
        .o_reg_rd_wait (reg_rd_wait),
        .o_reg_rd_data (reg_rd_data),
        .o_reg_ack     (reg_ack),
        .o_reg_err     (reg_err),
        
        // Register control signal
        .reg_uart_en   (reg_uart_en),
        .reg_uart_csr  (reg_uart_csr),
        .reg_uart_sta  (reg_uart_sta),
        .reg_uart_mode (reg_uart_mode),
        .reg_uart_brg  (reg_uart_brg),
        .reg_uart_ie   (reg_uart_ie),
        .reg_uart_if   (reg_uart_if),
        .reg_uart_ifclr(reg_uart_ifclr)
    );

endmodule
