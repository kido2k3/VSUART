//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart (top module)
//-- History         : ver.1.00 (26/10/17) 1st release
//--                 :
//===========================================================================
module vsuart #(
	parameter ADDR_W            = 16,
	parameter DATA_W            = 32,
	parameter FIFO_DEPTH 		= 128,
	parameter FIFO_DATA_W       = 9,
	// do not replace following parameters
	parameter STRB_W            = DATA_W / 8
)(
	// GLOBAL RESET
	input								sys_clk,
	input                               rst_n,
	// APB INTERFACE
	input                               pclk,
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
	// UART INTERFACE
	input								i_rx,
	output								o_tx,
	// INTERRUPT
	output								o_txifs,
	output								o_rxifs,
	output								o_errifs
);
//---------------------------------------------------------------------------
	// PARAMETER HERE
	localparam REG_ADDR_W        = ADDR_W - 2;
//---------------------------------------------------------------------------
	// VARIABLE
	wire  [REG_ADDR_W - 1 : 0]        reg_addr;
	wire  [DATA_W - 1 : 0]            reg_wdata;
	wire  [DATA_W - 1 : 0]            reg_wmask;
	wire                              reg_wen; // 1: write, 0: read
	wire  [DATA_W - 1 : 0]            reg_rdata;
	wire                              reg_ready; 
	wire                              reg_slverr;
	// UART SIDE
	// mode register
	wire [2 : 0] mode_uen;
	wire  mode_bsel;
	wire [1 : 0] mode_pdsel;
	wire  mode_spsel;
	// cr register
	wire [1 : 0] cr_txisel;
	wire [1 : 0] cr_rxisel;
	// sta register
	wire  sta_tbsta;
	wire  sta_trsta;
	wire  sta_tista;
	wire  sta_frerr;
	wire  sta_prerr;
	wire  sta_rista;
	wire  sta_rbosta;
	wire  sta_rbdsta;
	// prs register
	wire [3 : 0] prs_prs;
	// brg register
	wire [15 : 0] brg_brg;
	// INTERRUPT SIDE
	// ie register
	wire  ie_txte;
	wire  ie_rxte;
	wire  ie_errie;
	// ifs register
	wire  ifs_txifs;
	wire  ifs_rxifs;
	wire  ifs_errifs;
	wire  reg_ifs_txifs;
	wire  reg_ifs_rxifs;
	wire  reg_ifs_errifs;
	// uart clk
	wire u_clk;
	wire                        tx_wen;
	wire [FIFO_DATA_W - 1  : 0] tx_wdata;
	wire                        tx_ready;
	wire                        rx_ready;
	// FIFO
	wire                              tx_en;
	wire                              tx_ren;
	wire                              tx_empty;
	wire [FIFO_DATA_W - 1   :0]       tx_rdata;
	wire [FIFO_DATA_W - 1  : 0]       rx_rdata;
	wire                              rx_ren;
	wire                              ifs_txifs0;
	wire                              ifs_txifs1;
	wire                              ifs_txifs2;
	wire                              ifs_txifs3;
	// tx side
	wire tx_sta_trsta;
	wire tx_sta_tista;
	// rx side
	wire                              	rx_en;
	wire								rx_wen;
	wire 	[FIFO_DATA_W - 1  : 0]      rx_wdata;
	wire								rx_full;
	wire  								rx_sta_frerr;
	wire  								rx_sta_prerr;
	wire  								rx_sta_rista;
	wire  								rx_sta_rbosta;
    wire                                fifo_empty;
//     initial begin
//         $display("hello world");
//     end
//---------------------------------------------------------------------------
	// apb slave
	vsuart_apb_slv #(
		.ADDR_W          (ADDR_W),
		.DATA_W          (DATA_W),
		.FIFO_DATA_W     (FIFO_DATA_W)
	) u_vsuart_apb_slv (
		// GLOBAL RESET
		.rst_n           (rst_n),
		// APB INTERFACE
		.preset_n        (preset_n),
		.i_paddr         (i_paddr),
		.i_psel          (i_psel),
		.i_penable       (i_penable),
		.i_pwrite        (i_pwrite),
		.i_pwdata        (i_pwdata),
		.i_pstrb         (i_pstrb),
		.o_pready        (o_pready),
		.o_prdata        (o_prdata),
		.o_pslverr       (o_pslverr),
		// REGISTER SIDE
		.o_reg_addr      (reg_addr),
		.o_reg_wdata     (reg_wdata),
		.o_reg_wmask     (reg_wmask),
		// 1: write, 0: read
		.o_reg_wen       (reg_wen),
		.i_reg_rdata     (reg_rdata),
		.i_reg_ready     (reg_ready),
		.i_reg_slverr    (reg_slverr),
		// UART SIDE
		.i_tx_ready      (tx_ready),
		.o_tx_wdata      (tx_wdata),
		.o_tx_wren       (tx_wen),
		.i_rx_ready      (rx_ready),
		.i_rx_empty      (fifo_empty),
		.i_rx_rdata      (rx_rdata),
		.o_rx_rden       (rx_ren)
	);
	// register bank
	vsuart_reg #(
		.REG_ADDR_W      (REG_ADDR_W),
		.REG_DATA_W      (DATA_W)
	) u_vsuart_reg (
		.clk             (pclk),
		.rst_n           (rst_n),
		// APB SLAVE SIDE
		.i_reg_addr      (reg_addr),
		.i_reg_wdata     (reg_wdata),
		.i_reg_wmask     (reg_wmask),
		// 1: write, 0: read
		.i_reg_wen       (reg_wen),
		.o_reg_rdata     (reg_rdata),
		.o_reg_ready     (reg_ready),
		.o_reg_slverr    (reg_slverr),
		// UART SIDE
		// mode register
		.o_mode_uen      (mode_uen),
		.o_mode_bsel     (mode_bsel),
		.o_mode_pdsel    (mode_pdsel),
		.o_mode_spsel    (mode_spsel),
		// cr register
		.o_cr_txisel     (cr_txisel),
		.o_cr_rxisel     (cr_rxisel),
		// sta register
		.i_sta_tbsta     (sta_tbsta),
		.i_sta_trsta     (sta_trsta),
		.i_sta_tista     (sta_tista),
		.i_sta_frerr     (sta_frerr),
		.i_sta_prerr     (sta_prerr),
		.i_sta_rista     (sta_rista),
		.i_sta_rbosta    (sta_rbosta),
		.i_sta_rbdsta    (sta_rbdsta),
		// prs register
		.o_prs_prs       (prs_prs),
		// brg register
		.o_brg_brg       (brg_brg),
		// INTERRUPT SIDE
		// ie register
		.o_ie_txte       (ie_txte),
		.o_ie_rxte       (ie_rxte),
		.o_ie_errie      (ie_errie),
		// ifs register
		.i_ifs_txifs     (ifs_txifs),
		.o_ifs_txifs     (reg_ifs_txifs),
		.i_ifs_rxifs     (ifs_rxifs),
		.o_ifs_rxifs     (reg_ifs_rxifs),
		.i_ifs_errifs    (ifs_errifs),
		.o_ifs_errifs    (reg_ifs_errifs)
	);
	// interrupt
	vsuart_ifs u_vsuart_ifs (
		// interrupt enable
		.i_ie_txte       (ie_txte),
		.i_ie_rxte       (ie_rxte),
		.i_ie_errie      (ie_errie),
		// interrupt flag
		.i_ifs_txifs     (reg_ifs_txifs),
		.i_ifs_rxifs     (reg_ifs_rxifs),
		.i_ifs_errifs    (reg_ifs_errifs),
		// interrupt output
		.o_txifs         (o_txifs),
		.o_rxifs         (o_rxifs),
		.o_errifs        (o_errifs)
	);
	// prescaler
	vsuart_prs u_vsuart_prs (
		.clk      (sys_clk),
		.rst_n    (rst_n),
		.i_en     (mode_uen[2]),
		.i_prs    (prs_prs),
		.u_clk    (u_clk)
	);
	// synchronizer apb to uart
	vsuart_sync_a2u #(
		.FIFO_DEPTH      (FIFO_DEPTH),
		.FIFO_DATA_W     (FIFO_DATA_W)
	) u_vsuart_sync_a2u (
		// global reset
		.rst_n           (rst_n),
		// apb side
		.pclk            (pclk),
		.i_mode_uen      (mode_uen),
		.i_tx_wen        (tx_wen),
		.i_tx_wdata      (tx_wdata),
		.o_tx_ready      (tx_ready),
		.o_sta_tbsta     (sta_tbsta),
		.o_rx_ready      (rx_ready),
		// tx side
		.u_clk           (u_clk),
		.o_tx_en         (tx_en),
		.i_tx_ren        (tx_ren),
		.o_tx_empty      (tx_empty),
		.o_tx_rdata      (tx_rdata),
		.o_ifs_txifs3    (ifs_txifs3),
		// rx side
		.o_rx_en         (rx_en)
	);
	// synchronizer uart to apb
	vsuart_sync_u2a #(
		.FIFO_DEPTH      (FIFO_DEPTH),
		.FIFO_DATA_W     (FIFO_DATA_W)
	) u_vsuart_sync_u2a (
		// global reset
		.rst_n           (rst_n),
		// tx side
		.u_clk           (u_clk),
		.i_ifs_txifs0    (ifs_txifs0),
		.i_ifs_txifs1    (ifs_txifs1),
		.i_ifs_txifs2    (ifs_txifs2),
		.i_ifs_txifs3    (ifs_txifs3),
		.i_sta_trsta     (tx_sta_trsta),
		.i_sta_tista     (tx_sta_tista),
		// rx side
		.i_rx_wen        (rx_wen),
		.i_rx_wdata      (rx_wdata),
		.o_rx_full       (rx_full),
		.i_sta_frerr     (rx_sta_frerr),
		.i_sta_prerr     (rx_sta_prerr),
		.i_sta_rista     (rx_sta_rista),
		.i_sta_rbosta    (rx_sta_rbosta),
        .o_fifo_empty    (fifo_empty),
		// apb side
		.pclk            (pclk),
		.i_rx_ren        (rx_ren),
		.i_cr_txisel     (cr_txisel),
		.i_cr_rxisel     (cr_rxisel),
		.o_rx_rdata      (rx_rdata),
		.o_sta_rbdsta    (sta_rbdsta),
		// cdc
		.o_ifs_errifs    (ifs_errifs),
		.o_ifs_txifs     (ifs_txifs),
		.o_ifs_rxifs     (ifs_rxifs),
		.o_sta_trsta     (sta_trsta),
		.o_sta_tista     (sta_tista),
		.o_sta_frerr     (sta_frerr),
		.o_sta_prerr     (sta_prerr),
		.o_sta_rista     (sta_rista),
		.o_sta_rbosta    (sta_rbosta)
	);
	// uart tx
	vsuart_tx #(
		.FIFO_DATA_W     (FIFO_DATA_W)
	) u_vsuart_tx (
		.clk             (u_clk),
		.rst_n           (rst_n),
		// fifo
		.i_tx_en         (tx_en),
		.i_tx_empty      (tx_empty),
		.i_tx_rdata      (tx_rdata),
		.o_tx_ren        (tx_ren),
		// register
		.i_mode_bsel     (mode_bsel),
		.i_mode_pdsel    (mode_pdsel),
		.i_mode_spsel    (mode_spsel),
		.o_sta_trsta     (tx_sta_trsta),
		.o_sta_tista     (tx_sta_tista),
		.i_brg_brg       (brg_brg),
		// interrupt
		.o_ifs_txifs0    (ifs_txifs0),
		.o_ifs_txifs1    (ifs_txifs1),
		.o_ifs_txifs2    (ifs_txifs2),
		// uart
		.o_tx            (o_tx)
	);
	// uart rx
	vsuart_rx #(
		.FIFO_DATA_W     (FIFO_DATA_W)
	) u_vsuart_rx (
		.clk             (u_clk),
		.rst_n           (rst_n),
		.i_rx_en         (rx_en),
		// fifo
		.i_rx_full       (rx_full),
		.o_rx_wdata      (rx_wdata),
		.o_rx_wen        (rx_wen),
		// control
		.i_mode_bsel     (mode_bsel),
		// High baud rate Enable bit 
		.i_mode_pdsel    (mode_pdsel),
		.i_mode_spsel    (mode_spsel),
		.i_brg           (brg_brg),
		// rx side
		.i_rx            (i_rx),
		.o_sta_frerr     (rx_sta_frerr),
		.o_sta_prerr     (rx_sta_prerr),
		.o_sta_rista     (rx_sta_rista),
		.o_sta_rbosta    (rx_sta_rbosta)
	);
//---------------------------------------------------------------------------
endmodule
