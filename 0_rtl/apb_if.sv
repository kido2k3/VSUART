//----------------------------------------------------------------------
// Title      : APB Interface
// Description: 
//   This file defines the Advanced Peripheral Bus (APB) interface.
//   It includes all standard APB signals and provides modports for
//   master, slave, and monitor roles to specify signal directions.
// Signal names are modified to follow a naming convention:
//     - *_i: Input to module (driven by master)
//     - *_o: Output from module (driven by slave)
//----------------------------------------------------------------------

interface apb_if;

  //--------------------------------------------------------------------
  // Clock and Reset Signals
  //--------------------------------------------------------------------
  logic pclk;
  logic presetn;

  //--------------------------------------------------------------------
  // APB Control Signals
  //--------------------------------------------------------------------
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [3:0]  pstrb;
  logic [2:0]  pprot;

  //--------------------------------------------------------------------
  // APB Address and Data Signals
  //--------------------------------------------------------------------
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;

  //--------------------------------------------------------------------
  // APB Response Signals
  //--------------------------------------------------------------------
  logic pready;
  logic pslverr;

  //--------------------------------------------------------------------
  // Modport for APB Master
  //--------------------------------------------------------------------
  modport master_cb (
    output paddr,
    output pwdata,
    output pwrite,
    output psel,
    output penable,
    output pstrb,
    output pprot,

    input  prdata,
    input  pready,
    input  pslverr,

    input  pclk,
    input  presetn
  );

  //--------------------------------------------------------------------
  // Modport for APB Slave
  //--------------------------------------------------------------------
  modport slave_cb (
    input  paddr,
    input  pwdata,
    input  pwrite,
    input  psel,
    input  penable,
    input  pstrb,
    input  pprot,

    input  pclk,
    input  presetn,

    output prdata,
    output pready,
    output pslverr
  );

  //--------------------------------------------------------------------
  // Modport for APB Monitor
  //--------------------------------------------------------------------
  modport monitor_cb (
    input  paddr,
    input  pwdata,
    input  pwrite,
    input  psel,
    input  penable,
    input  pstrb,
    input  pprot,

    input  prdata,
    input  pready,
    input  pslverr,

    input  pclk,
    input  presetn
  );

endinterface : apb_if
