//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_if
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
interface ifs_if(input clk, input rst_n);
    logic txifs;  
    logic rxifs;  
    logic errifs; 

    //samples before posedge
    clocking mon_if @(posedge clk);
        default input #1step;
        input txifs, rxifs, errifs;
    endclocking

endinterface
