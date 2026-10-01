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
// Common defines
`define ADDR_W 14
`define DATA_W 32

// VSUART_MODE at address 14'h0000
`define VSUART_MODE_ADDR 14'h0000
`define VSUART_MODE_POR 32'h0001_0000

`define VSUART_MODE_MASK 32'h0103_0107

// VSUART_CR at address 14'h0004
`define VSUART_CR_ADDR 14'h0004
`define VSUART_CR_POR 32'h0000_0000

`define VSUART_CR_MASK 32'h0000_0303

// VSUART_STA at address 14'h0008
`define VSUART_STA_ADDR 14'h0008
`define VSUART_STA_POR 32'h0000_0000

`define VSUART_STA_MASK 32'h0000_0018

// VSUART_PRS at address 14'h000C
`define VSUART_PRS_ADDR 14'h000C
`define VSUART_PRS_POR 32'h0000_0000

`define VSUART_PRS_MASK 32'h0000_000F

// VSUART_BRG at address 14'h0010
`define VSUART_BRG_ADDR 14'h0010
`define VSUART_BRG_POR 32'h0000_0001

`define VSUART_BRG_MASK 32'h0000_FFFF

// VSUART_IE at address 14'h0014
`define VSUART_IE_ADDR 14'h0014
`define VSUART_IE_POR 32'h0001_0101

`define VSUART_IE_MASK 32'h0001_0101

// VSUART_IFS at address 14'h0018
`define VSUART_IFS_ADDR 14'h0018
`define VSUART_IFS_POR 32'h0000_0000

`define VSUART_IFS_MASK 32'h0001_0101

// VSUART_MODE detail
`define MODE_UEN 3'b000
`define MODE_BSEL 1'b0
`define MODE_PDSEL 2'b01
`define MODE_SPSEL 1'b0

// VSUART_CR detail
`define CR_TXISEL 2'b00
`define CR_RXISEL 2'b00

// VSUART_STA detail
`define STA_TBSTA 1'b0
`define STA_TRSTA 1'b0
`define STA_TISTA 1'b0
`define STA_FRERR 1'b0
`define STA_PRERR 1'b0
`define STA_RISTA 1'b0
`define STA_RBOSTA 1'b0
`define STA_RBDSTA 1'b0

// VSUART_PRS detail
`define PRS_PRS 4'b0

// VSUART_BRG detail
`define BRG_BRG 16'b1

// VSUART_IE detail
`define IE_TXTE 1'b1
`define IE_RXTE 1'b1
`define IE_ERRIE 1'b1

// VSUART_IFS detail
`define IFS_TXIFS 1'b0
`define IFS_RXIFS 1'b0
`define IFS_ERRIFS 1'b0



//===========================================================================
`endif