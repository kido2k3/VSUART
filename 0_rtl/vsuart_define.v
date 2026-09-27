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

// Mask at address 14
`define Mask_ADDR 14
`define Mask_POR 32

`define Mask_MASK 32

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

`define VSUART_STA_MASK 32'h0000_0000

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

`define VSUART_IFS_MASK 32'h0000_0000

// VSUART_MODE detail
`define MODE_UEN 33'b000
`define MODE_BSEL 11'b0
`define MODE_PDSEL 22'b01
`define MODE_SPSEL 11'b0

// VSUART_CR detail
`define CR_TXISEL 22'b00
`define CR_RXISEL 22'b00

// VSUART_STA detail
`define STA_TBSTA 11'b0
`define STA_TRSTA 11'b0
`define STA_TISTA 11'b0
`define STA_FRERR 11'b0
`define STA_PRERR 11'b0
`define STA_RISTA 11'b0
`define STA_RBOSTA 11'b0
`define STA_RBDSTA 11'b0

// VSUART_PRS detail
`define PRS_PRS 44'b0

// VSUART_BRG detail
`define BRG_BRG 1616'b1

// VSUART_IE detail
`define IE_TXTE 11'b1
`define IE_RXTE 11'b1
`define IE_ERRIE 11'b1

// VSUART_IFS detail
`define IFS_TXIFS 11'b0
`define IFS_RXIFS 11'b0
`define IFS_ERRIFS 11'b0

// VSUART_IFC detail
`define IFC_TXIFC 11'b0
`define IFC_RXIFC 11'b0
`define IFC_ERRIFC 11'b0


//===========================================================================
`endif