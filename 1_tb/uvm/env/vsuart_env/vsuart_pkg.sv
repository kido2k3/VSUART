//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_pkg (vsuart  package)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
//** clk reset package**
`include "clk_rst_pkg.sv"
import clk_rst_pkg::*;

package vsuart_pkg;
    import uvm_pkg::*;
    import clk_rst_pkg::*;
    // vsuart file
    `include "vsuart_cfg.sv"
    `include "vsuart_env.sv"
endpackage

