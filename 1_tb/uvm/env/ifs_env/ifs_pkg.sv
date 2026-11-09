//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_pkg (interrupt package)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

`include "ifs_if.sv"
package ifs_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Named event keys for uvm_event_pool
    parameter string EV_TX_IRQ  = "vsuart_tx_irq";
    parameter string EV_RX_IRQ  = "vsuart_rx_irq";
    parameter string EV_ERR_IRQ = "vsuart_err_irq";

    `include "irq_item.sv"
    `include "irq_mon.sv"
    `include "irq_agt.sv"
    `include "ifs_env.sv"
endpackage
