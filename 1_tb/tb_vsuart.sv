`timescale 100 ps/100 ps

// include vsuart package
`include "vsuart_pkg.sv"
import vsuart_pkg::*;

module tb_vsuart;
    
clk_rst_if clk_rst_vif();
apb_mst_if apb_mst_vif(clk_rst_vif.apb_clk);
assign apb_mst_vif.rst_n = clk_rst_vif.rst_n;

uart_if uart_vif(.clk(clk_rst_vif.sys_clk), .rst_n(clk_rst_vif.rst_n));

ifs_if ifs_vif(.clk(clk_rst_vif.apb_clk), .rst_n(clk_rst_vif.rst_n));

// DUT: the APB address is 16-bit, the agent drives the lower bits of paddr
vsuart u_dut (
    .sys_clk    (clk_rst_vif.sys_clk),
    .rst_n      (clk_rst_vif.rst_n),
    .pclk       (clk_rst_vif.apb_clk),
    .preset_n   (clk_rst_vif.rst_n),
    .i_paddr    (apb_mst_vif.paddr[15:0]),
    .i_psel     (apb_mst_vif.psel),
    .i_penable  (apb_mst_vif.penable),
    .i_pwrite   (apb_mst_vif.pwrite),
    .i_pwdata   (apb_mst_vif.pwdata),
    .i_pstrb    (apb_mst_vif.pstrb),
    .o_pready   (apb_mst_vif.pready),
    .o_prdata   (apb_mst_vif.prdata),
    .o_pslverr  (apb_mst_vif.pslverr),
    .i_rx       (uart_vif.u_rx),
    .o_tx       (uart_vif.u_tx),
    .o_txifs    (ifs_vif.txifs),
    .o_rxifs    (ifs_vif.rxifs),
    .o_errifs   (ifs_vif.errifs)
);

    initial begin
    `ifdef WAVE
        `ifdef VCS        
        // dve wave dump
        $vcdplusfile ("wave.vpd");
        $vcdpluson;
        `elsif XRUN
        // simvision wave dump
        $shm_open("waves.shm");
        $shm_probe("AS");
        `endif
    `endif
        // set database
        uvm_config_db #(virtual clk_rst_if)::set(null, "*", "clk_rst_vif", clk_rst_vif);
        uvm_config_db #(virtual apb_mst_if)::set(null, "*", "apb_mst_vif", apb_mst_vif);
        uvm_config_db #(virtual uart_if)::set(null, "*", "uart_vif", uart_vif);
        uvm_config_db #(virtual ifs_if)::set(null, "*", "ifs_vif", ifs_vif);

        // run test
        run_test();
    end
endmodule
