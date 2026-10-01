//===========================================================================
//-- Author          : kido
//-- IP Name         : vsuart_reg (registers)
//-- History         : ver.1.00 (26/10/2) 1st release
//--                 :
//===========================================================================
module vsuart_reg #(
    parameter REG_ADDR_W        = 14,
    parameter REG_NUM           = 8,
    parameter REG_DATA_W        = 32
) (
    input                               clk,
    input                               rst_n,
    // APB SLAVE SIDE
    input   [REG_ADDR_W - 1   : 0]      i_reg_addr,
    input   [REG_DATA_W - 1   : 0]      i_reg_wdata,
    input   [REG_DATA_W - 1   : 0]      i_reg_wmask,
    input                               i_reg_wen, // 1: write, 0: read
    output  [REG_DATA_W - 1   : 0]      o_reg_rdata,
    output                              o_reg_ready, 
    output                              o_reg_slverr,
    // UART SIDE
    // mode register
    output [2 : 0] o_mode_uen,
    output  o_mode_bsel,
    output [1 : 0] o_mode_pdsel,
    output  o_mode_spsel,
    // cr register
    output [1 : 0] o_cr_txisel,
    output [1 : 0] o_cr_rxisel,
    // sta register
    input  i_sta_tbsta,
    input  i_sta_trsta,
    input  i_sta_tista,
    input  i_sta_frerr,
    input  i_sta_prerr,
    input  i_sta_rista,
    input  i_sta_rbosta,
    input  i_sta_rbdsta,
    // prs register
    output [3 : 0] o_prs_prs,
    // brg register
    output [15 : 0] o_brg_brg,
    // INTERRUPT SIDE
    // ie register
    output  o_ie_txte,
    output  o_ie_rxte,
    output  o_ie_errie,
    // ifs register
    input  i_ifs_txifs,
    output  o_ifs_txifs,
    input  i_ifs_rxifs,
    output  o_ifs_rxifs,
    input  i_ifs_errifs,
    output  o_ifs_errifs
);
//---------------------------------------------------------------------------
    // PARAMETER HERE
//---------------------------------------------------------------------------
    // VARIABLE
    // for ready and slverr
    reg reg_ready;
    reg reg_slverr;
    // Register wires start
    // mode register
    wire [REG_DATA_W-1:0] reg_mode;
    // cr register
    wire [REG_DATA_W-1:0] reg_cr;
    // sta register
    wire [REG_DATA_W-1:0] reg_sta;
    wire [REG_DATA_W-1:0] wmask_sta;
    wire [REG_DATA_W-1:0] wdata_sta;
    // prs register
    wire [REG_DATA_W-1:0] reg_prs;
    // brg register
    wire [REG_DATA_W-1:0] reg_brg;
    // ie register
    wire [REG_DATA_W-1:0] reg_ie;
    // ifs register
    wire [REG_DATA_W-1:0] reg_ifs;
    wire [REG_DATA_W-1:0] wmask_ifs;
    wire [REG_DATA_W-1:0] wdata_ifs;
    // Register wires end
//---------------------------------------------------------------------------
    // assign wmask and wdata
    // sta register
    assign wmask_sta[0] = 1;
    assign wdata_sta[0] = i_sta_tbsta;
    assign wmask_sta[1] = 1;
    assign wdata_sta[1] = i_sta_trsta;
    assign wmask_sta[2] = 1;
    assign wdata_sta[2] = i_sta_tista;
    assign wmask_sta[3] = i_sta_frerr;
    assign wdata_sta[3] = i_sta_frerr;
    assign wmask_sta[4] = i_sta_prerr;
    assign wdata_sta[4] = i_sta_prerr;
    assign wmask_sta[5] = 1;
    assign wdata_sta[5] = i_sta_rista;
    assign wmask_sta[6] = 1;
    assign wdata_sta[6] = i_sta_rbosta;
    assign wmask_sta[7] = 1;
    assign wdata_sta[7] = i_sta_rbdsta;
    assign wmask_sta[31:8] = 0;
    assign wdata_sta[31:8] = 0;
    // ifs register
    assign wmask_ifs[0] = i_ifs_txifs;
    assign wdata_ifs[0] = i_ifs_txifs;
    assign wmask_ifs[7:1] = 0;
    assign wdata_ifs[7:1] = 0;
    assign wmask_ifs[8] = i_ifs_rxifs;
    assign wdata_ifs[8] = i_ifs_rxifs;
    assign wmask_ifs[15:9] = 0;
    assign wdata_ifs[15:9] = 0;
    assign wmask_ifs[16] = i_ifs_errifs;
    assign wdata_ifs[16] = i_ifs_errifs;
    assign wmask_ifs[31:17] = 0;
    assign wdata_ifs[31:17] = 0;
//---------------------------------------------------------------------------
    // register model start
    // reg_mode model
    wr_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_MODE_ADDR >> 2),
        .MASK(`VSUART_MODE_MASK),
        .POR_VAL(`VSUART_MODE_POR)
    ) u_reg_mode(
        .clk(clk),
        .rst_n(rst_n),
        .i_addr(i_reg_addr),
        .i_wen(i_reg_wen),
        .i_wdata(i_reg_wdata),
        .i_wmask(i_reg_wmask),
        .o_rdata(reg_mode)
    );

    // reg_cr model
    wr_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_CR_ADDR >> 2),
        .MASK(`VSUART_CR_MASK),
        .POR_VAL(`VSUART_CR_POR)
    ) u_reg_cr(
        .clk(clk),
        .rst_n(rst_n),
        .i_addr(i_reg_addr),
        .i_wen(i_reg_wen),
        .i_wdata(i_reg_wdata),
        .i_wmask(i_reg_wmask),
        .o_rdata(reg_cr)
    );

    // reg_sta model
    r1c_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_STA_ADDR >> 2),
        .MASK({REG_DATA_W{1'b1}}),
        .MASK_CLR(`VSUART_STA_MASK),
        .POR_VAL(`VSUART_STA_POR)
    ) u_reg_sta(
        .clk(clk),
        .rst_n(rst_n),
        // INTERNAL USE: write via mask
        .i_wdata(wdata_sta),
        .i_wmask(wmask_sta),
        // USER USE
        .i_addr_clr(i_reg_addr),
        .i_ren_clr(~i_reg_wen),
        .o_rdata(reg_sta)
    );

    // reg_prs model
    wr_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_PRS_ADDR >> 2),
        .MASK(`VSUART_PRS_MASK),
        .POR_VAL(`VSUART_PRS_POR)
    ) u_reg_prs(
        .clk(clk),
        .rst_n(rst_n),
        .i_addr(i_reg_addr),
        .i_wen(i_reg_wen),
        .i_wdata(i_reg_wdata),
        .i_wmask(i_reg_wmask),
        .o_rdata(reg_prs)
    );

    // reg_brg model
    wr_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_BRG_ADDR >> 2),
        .MASK(`VSUART_BRG_MASK),
        .POR_VAL(`VSUART_BRG_POR)
    ) u_reg_brg(
        .clk(clk),
        .rst_n(rst_n),
        .i_addr(i_reg_addr),
        .i_wen(i_reg_wen),
        .i_wdata(i_reg_wdata),
        .i_wmask(i_reg_wmask),
        .o_rdata(reg_brg)
    );

    // reg_ie model
    wr_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_IE_ADDR >> 2),
        .MASK(`VSUART_IE_MASK),
        .POR_VAL(`VSUART_IE_POR)
    ) u_reg_ie(
        .clk(clk),
        .rst_n(rst_n),
        .i_addr(i_reg_addr),
        .i_wen(i_reg_wen),
        .i_wdata(i_reg_wdata),
        .i_wmask(i_reg_wmask),
        .o_rdata(reg_ie)
    );

    // reg_ifs model
    w1c_reg #(
        .ADDR_W(REG_ADDR_W),
        .DATA_W(REG_DATA_W),
        .ADDR(`VSUART_IFS_ADDR >> 2),
        .MASK({REG_DATA_W{1'b1}}),
        .MASK_CLR(`VSUART_IFS_MASK),
        .POR_VAL(`VSUART_IFS_POR)
    ) u_reg_ifs(
        .clk(clk),
        .rst_n(rst_n),
        // INTERNAL USE: write via mask
        .i_wdata(wdata_ifs),
        .i_wmask(wmask_ifs),
        // USER USE
        .i_addr_clr(i_reg_addr),
        .i_wen_clr(i_reg_wen),
        .i_wdata_clr(i_reg_wdata),
        .i_wmask_clr(i_reg_wmask),
        .o_rdata(reg_ifs)
    );

    // register model end
//---------------------------------------------------------------------------
    // UART SIDE
    // mode register
    assign o_mode_uen = reg_mode[2:0];
    assign o_mode_bsel = reg_mode[8];
    assign o_mode_pdsel = reg_mode[17:16];
    assign o_mode_spsel = reg_mode[24];
    // cr register
    assign o_cr_txisel = reg_cr[1:0];
    assign o_cr_rxisel = reg_cr[9:8];
    // sta register
    // prs register
    assign o_prs_prs = reg_prs[3:0];
    // brg register
    assign o_brg_brg = reg_brg[15:0];
//---------------------------------------------------------------------------
    // INTERRUPT SIDE
    // ie register
    assign o_ie_txte = reg_ie[0];
    assign o_ie_rxte = reg_ie[8];
    assign o_ie_errie = reg_ie[16];
    // ifs register
    assign o_ifs_txifs = reg_ifs[0];
    assign o_ifs_rxifs = reg_ifs[8];
    assign o_ifs_errifs = reg_ifs[16];
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
endmodule