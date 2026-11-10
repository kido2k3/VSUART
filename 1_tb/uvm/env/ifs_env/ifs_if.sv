//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_if & irq_if
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================

// Generic interrupt interface (reusable)
interface irq_if(input clk, input rst_n, input irq);

    clocking mon_if @(posedge clk);
        default input #1step;
        input irq;
    endclocking
endinterface

// Top-level interrupt interface bundle
interface ifs_if(input clk, input rst_n);
    logic txifs;  
    logic rxifs;  
    logic errifs; 

    // 3 dedicated single-wire sub-interfaces for the 3 interrupt agents
    irq_if tx_if(.clk(clk),  .rst_n(rst_n), .irq(txifs));
    irq_if rx_if(.clk(clk),  .rst_n(rst_n), .irq(rxifs));
    irq_if err_if(.clk(clk), .rst_n(rst_n), .irq(errifs));

endinterface
