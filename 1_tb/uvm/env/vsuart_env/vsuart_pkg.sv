//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_pkg (vsuart  package)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
//** clk reset package**
`include "clk_rst_pkg.sv"
import clk_rst_pkg::*;

//** apb master package**
`include "apb_mst_pkg.sv"
import apb_mst_pkg::*;

//** uart package**
`include "uart_pkg.sv"
import uart_pkg::*;

package vsuart_pkg;
    import uvm_pkg::*;
    import clk_rst_pkg::*;
    import apb_mst_pkg::*;
    import uart_pkg::*;  
    // vsuart file
    `include "vsuart_cfg.sv"
    `include "vsuart_env.sv"
endpackage

