`timescale 100 ps/100 ps

// include vsuart package
`include "vsuart_pkg.sv"
import vsuart_pkg::*;

module tb_vsuart;
    
clk_rst_if clk_rst_vif();
    
    initial begin
    `ifdef WAVE
        `ifdef VCS        
        // dve wave dump
        $vcdplusfile ("wave.vpd");
        $vcdpluson;
        `elsif XRUN
        // .......
        `endif
    `endif
        // set database
        uvm_config_db #(virtual clk_rst_if)::set(null, "*", "clk_rst_vif", clk_rst_vif);

        // run test
        run_test();
    end
endmodule
