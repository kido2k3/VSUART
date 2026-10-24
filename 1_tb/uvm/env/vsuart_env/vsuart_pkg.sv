//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_pkg (vsuart  package)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                : ver.1.01 (26/10/17) add register layer (ral) + uart agent
//--                : ver.1.02 (26/10/17) add ifs (interrupt) agent
//===========================================================================
//***** uvm package ****
import uvm_pkg::*;
`include "uvm_macros.svh"

//** clk reset package**
`include "clk_rst_pkg.sv"
import clk_rst_pkg::*;

//** apb master package**
`include "apb_mst_pkg.sv"
import apb_mst_pkg::*;

//** uart package**
`include "uart_pkg.sv"
import uart_pkg::*;

//** ifs (interrupt) package**
`include "ifs_pkg.sv"
import ifs_pkg::*;

//** register layer: model, adapter, predictor, sequences **
`include "ral_pkg.sv"
import ral_pkg::*;

package vsuart_pkg;
    import uvm_pkg::*;
    import clk_rst_pkg::*;
    import apb_mst_pkg::*;
    import uart_pkg::*;
    import ifs_pkg::*;
    import ral_pkg::*;
    // vsuart file
    `include "vsuart_cfg.sv"
    `include "vsuart_scb.sv"
    `include "vsuart_env.sv"
endpackage

