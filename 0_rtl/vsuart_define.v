//===========================================================================
//-- Author          : manhndd
//-- Name            : vsuart_define
//-- History         : ver.0.01 (26/03/05)
//--                 : 
//===========================================================================
`ifndef vsuart_define
`define vsuart_define
//---------------------------------------------------------------------------
// UART state
`define IDLE        5'b00001
`define START_BIT   5'b00010
`define DATA		5'b00100
`define PARITY		5'b01000
`define STOP_BIT 	5'b10000
// Common defines
`define FIFO_DEPTH 32
`define FIFO_DATA_W 9
`define ADDR_W 16
`define DATA_W 32

// VSUART_MODE at address 14'h0000
`define VSUART_MODE_ADDR (14'h0000 >> 2)
`define VSUART_MODE_POR 32'h0001_0000
`define VSUART_MODE_MASK 32'h0103_0107

// VSUART_CR at address 14'h0004
`define VSUART_CR_ADDR (14'h0004 >> 2)
`define VSUART_CR_POR 32'h0000_0000
`define VSUART_CR_MASK 32'h0000_0303

// VSUART_STA at address 14'h0008
`define VSUART_STA_ADDR (14'h0008 >> 2)
`define VSUART_STA_POR 32'h0000_0024
`define VSUART_STA_MASK 32'h0000_0058

// VSUART_PRS at address 14'h000C
`define VSUART_PRS_ADDR (14'h000C >> 2)
`define VSUART_PRS_POR 32'h0000_0000
`define VSUART_PRS_MASK 32'h0000_000F

// VSUART_BRG at address 14'h0010
`define VSUART_BRG_ADDR (14'h0010 >> 2)
`define VSUART_BRG_POR 32'h0000_0001
`define VSUART_BRG_MASK 32'h0000_FFFF

// VSUART_IE at address 14'h0014
`define VSUART_IE_ADDR (14'h0014 >> 2)
`define VSUART_IE_POR 32'h0000_0000
`define VSUART_IE_MASK 32'h0001_0101

// VSUART_IFS at address 14'h0018
`define VSUART_IFS_ADDR (14'h0018 >> 2)
`define VSUART_IFS_POR 32'h0000_0000
`define VSUART_IFS_MASK 32'h0001_0101

// VSUART_MODE detail
`define MODE_UEN 0
`define MODE_BSEL 0
`define MODE_PDSEL 1
`define MODE_SPSEL 0

// VSUART_CR detail
`define CR_TXISEL 0
`define CR_RXISEL 0

// VSUART_STA detail
`define STA_TBSTA 0
`define STA_TRSTA 0
`define STA_TISTA 1
`define STA_FRERR 0
`define STA_PRERR 0
`define STA_RISTA 1
`define STA_RBOSTA 0
`define STA_RBDSTA 0

// VSUART_PRS detail
`define PRS_PRS 0

// VSUART_BRG detail
`define BRG_BRG 1

// VSUART_IE detail
`define IE_TXTE 0
`define IE_RXTE 0
`define IE_ERRIE 0

// VSUART_IFS detail
`define IFS_TXIFS 0
`define IFS_RXIFS 0
`define IFS_ERRIFS 0

//===========================================================================
`endif

