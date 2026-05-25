//===========================================================================
//-- File Version    : 1.01
//-- Date            : 26/03/05
//-- Author          : manhndd
//-- Name            : vsuart_define
//-- History         : ver.0.01
//--                 : 
//===========================================================================
`ifndef vsuart_define
`define vsuart_define
//---------------------------------------------------------------------------
// REGISTER INITIAL VALUE
// UART_MODE (offset 0000h)
`define UART_MODE_UEN       3'b000
`define UART_MODE_BSEL      1'd0
`define UART_MODE_PDSEL     2'd1
`define UART_MODE_SPSEL     1'd0
// Power-on reset value
`define POR_UART_MODE       {7'd0, `UART_MODE_SPSEL, 6'd0, `UART_MODE_PDSEL, 7'd0, `UART_MODE_BSE, 5'd0, `UART_MODE_UEN}
// Register offset address
`define ADDR_UART_MODE      (16'h0 >> 2)

// UART_CR (offset 0004h)
`define UART_CR_TXISEL      2'b00
`define UART_CR_RXISEL      2'b00
// Power-on reset value
`define POR_UART_CR       {23'd0, `UART_CR_RXISEL, 2'd0, `UART_CR_TXISEL}
// Register offset address
`define ADDR_UART_CR        (16'h4 >> 2)

// UART_STA (offset 0008h)
`define UART_STA_TBSTA      1'b0
`define UART_STA_TRSTA      1'b0
`define UART_STA_TISTA      1'b0
`define UART_STA_FRERR      1'b0
`define UART_STA_PRERR      1'b0
`define UART_STA_RISTA      1'b0
`define UART_STA_RBOSTA     1'b0
`define UART_STA_RBDSTA     1'b0
// Power-on reset value
`define POR_UART_STA       {24'd0, `UART_STA_RBDSTA, `UART_STA_RBOSTA, `UART_STA_RISTA, `UART_STA_PRERR, `UART_STA_FRERR, `UART_STA_TISTA, `UART_STA_TRSTA, `UART_STA_TBSTA}
// Register offset address
`define ADDR_UART_STA      (16'h8 >> 2)

// UART_PRS (offset 000Ch)
// Power-on reset value
`define POR_UART_PRS       32'h0
// Register offset address
`define ADDR_UART_PRS       (16'hC >> 2)

// UART_BRG (offset 0010h)
// Power-on reset value
`define POR_UART_BRG       32'h1
// Register offset address
`define ADDR_UART_BRG      (16'h10 >> 2)

// UART_IE (offset 0014h)
`define UART_IE_TXIE      1'd1
`define UART_IE_RXIE      1'd1
`define UART_IE_ERRIE     1'd1
// Power-on reset value
`define POR_UART_IE       {15'd0, `UART_IFS_ERRIE, 7'd0, `UART_IFS_RXIE, 7'd0, `UART_IFS_TXIE}
// Register offset address
`define ADDR_UART_IE       (16'h14 >> 2)

// UART_IFS (offset 0018h)
`define UART_IFS_TXIFS      1'd0
`define UART_IFS_RXIFS      1'd0
`define UART_IFS_ERRIFS     1'd0
// Power-on reset value
`define POR_UART_IFS       {15'd0, `UART_IFS_ERRIFS, 7'd0, `UART_IFS_RXIFS, 7'd0, `UART_IFS_TXIFS}
// Register offset address
`define ADDR_UART_IFS       (16'h18 >> 2)

// UART_IFC (offset 001Ch)
`define UART_IFS_TXIFC      1'd0
`define UART_IFS_RXIFC      1'd0
`define UART_IFS_ERRIFC     1'd0
// Power-on reset value
`define POR_UART_IFC       {15'd0, `UART_IFS_ERRIFC, 7'd0, `UART_IFS_RXIFC, 7'd0, `UART_IFS_TXIFC}
// Register offset address
`define ADDR_UART_IFC       (16'h1C >> 2)

// REGISTER MASK
`define UART_MODE_MASK      32'h0103_0107
`define UART_CR_MASK        32'h0000_0103
`define UART_STA_MASK       32'h0000_0000
`define UART_PRS_MASK       32'h0000_000F
`define UART_BRG_MASK       32'h0000_FFFF
`define UART_IE_MASK        32'h0001_0101
`define UART_IFS_MASK       32'h0001_0101
`define UART_IFC_MASK       32'h0001_0101


//===========================================================================
`endif