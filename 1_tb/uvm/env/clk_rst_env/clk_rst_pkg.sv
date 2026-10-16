//===========================================================================
//-- Author         : kido
//-- Name           : clk_rst_pkg (clk reset package)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
//***** uvm package ****
`include "uvm_pkg.sv"
import uvm_pkg::*;

`include "clk_rst_if.sv"
package clk_rst_pkg;
    import uvm_pkg::*;

    `include "clk_cfg.sv"
    `include "rst_item.sv"
    `include "clk_rst_drv.sv"
    `include "clk_rst_mon.sv"
    `include "clk_rst_seqr.sv"
    `include "clk_rst_agt.sv"
endpackage
