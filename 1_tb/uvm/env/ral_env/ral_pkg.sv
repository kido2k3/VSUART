//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_pkg (vsuart register layer package)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
package ral_pkg;
    import uvm_pkg::*;
    import apb_mst_pkg::*;
    import clk_rst_pkg::*;
    `include "uvm_macros.svh"

    // register model
    `include "base_ral_reg.sv"
    `include "ral_reg_mode.sv"
    `include "ral_reg_cr.sv"
    `include "ral_reg_sta.sv"
    `include "ral_reg_prs.sv"
    `include "ral_reg_brg.sv"
    `include "ral_reg_ie.sv"
    `include "ral_reg_ifs.sv"
    `include "ral_blk.sv"

    // adapter, mirror reset and register environment (predictor: uvm_reg_predictor)
    `include "ral_apb_adp.sv"
    `include "ral_rst_sub.sv"
    `include "ral_env.sv"
endpackage
