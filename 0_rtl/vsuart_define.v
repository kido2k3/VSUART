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
Invalid switch - "/ Common defines"
`define ADDR_W 14
`define DATA_W 32

// VSUART_MODE at address 14'h0000
`define VSUART_MODE_ADDR 14'h0000
`define VSUART_MODE_POR 32'h0001_0000

// VSUART_CR at address 14'h0004
`define VSUART_CR_ADDR 14'h0004
`define VSUART_CR_POR 32'h0000_0000

// VSUART_STA at address 14'h0008
`define VSUART_STA_ADDR 14'h0008
`define VSUART_STA_POR 32'h0000_0000

// VSUART_PRS at address 14'h000C
`define VSUART_PRS_ADDR 14'h000C
`define VSUART_PRS_POR 32'h0000_0000

// VSUART_BRG at address 14'h0010
`define VSUART_BRG_ADDR 14'h0010
`define VSUART_BRG_POR 32'h0000_0001

// VSUART_IE at address 14'h0014
`define VSUART_IE_ADDR 14'h0014
`define VSUART_IE_POR 32'h0001_0101

// VSUART_IFS at address 14'h0018
`define VSUART_IFS_ADDR 14'h0018
`define VSUART_IFS_POR 32'h0000_0000

// UART_MODE detail
`define DE_UEN 3'b000

// ↑ detail
`define _BSEL 1'b0
`define _PDSEL 2'b01
`define _SPSEL 1'b0

// UART_CR detail
`define _TXISEL 2'b00

// ↑ detail
`define _RXISEL 2'b00

// UART_STA detail
`define A_TBSTA 1'b0

// ↑ detail
`define _TRSTA 1'b0
`define _TISTA 1'b0
`define _FRERR 1'b0
`define _PRERR 1'b0
`define _RISTA 1'b0
`define _RBOSTA 1'b0
`define _RBDSTA 1'b0

// UART_PRS detail
`define S_PRS 4'b0

// UART_BRG detail
`define G_BRG 16'b1

// UART_IE detail
`define _TXTE 1'b1

// ↑ detail
`define _RXTE 1'b1
`define _ERRIE 1'b1

// UART_IFS detail
`define S_TXIFS 1'b0

// ↑ detail
`define _RXIFS 1'b0
`define _ERRIFS 1'b0

// UART_IFC detail
`define C_TXIFC 1'b0

// ↑ detail
`define _RXIFC 1'b0
`define _ERRIFC 1'b0

//===========================================================================
`endif