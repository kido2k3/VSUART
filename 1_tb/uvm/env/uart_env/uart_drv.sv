//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_drv (uart driver)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================
class uart_drv extends uvm_driver #(uart_item);
`uvm_component_utils(uart_drv)

virtual uart_if vif;
uart_cfg cfg;

function new(string name = "uart_drv", uvm_component parent) ;
    super.new(name, parent);
endfunction

function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("build_phase", "Entered...", UVM_LOW)
   
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", vif))begin
        `uvm_fatal("NO_IF","Virtual interface not found")
    end

    if (!uvm_config_db#(uart_cfg)::get(this, "", "uart_cfg", cfg))begin
        `uvm_fatal("NO_CONFIG","Configured not found")
    end
    `uvm_info ("build phase","Exit....", UVM_LOW)

endfunction

task run_phase(uvm_phase phase);
    vif.drv_if.u_rx <= 1'b1;                     
    wait (vif.rst_n === 1'b1);                   
    forever begin
        seq_item_port.get(req);        
        if (!uvm_config_db#(uart_cfg)::get(this, "", "uart_cfg", cfg))begin
        `uvm_fatal("NO_CONFIG","Configured not found")
        end
        `uvm_info("DRV", $sformatf("Starting to drive transaction:\n%s", req.sprint()), UVM_LOW)
        
        `uvm_info("DRIVER_CFG", $sformatf("Update new configure to:\n%s", cfg.sprint()), UVM_LOW)
            drive_item(req); 
        seq_item_port.put(req);               
    end
endtask

task drive_item(uart_item item);
    bit bits[$];
    if (cfg.clks_per_bit < 2)
        `uvm_fatal("DRV_CFG", $sformatf("clks_per_bit=%0d, cfg not calculated yet", cfg.clks_per_bit))
    build_frame(bits, item);
    `uvm_info("DRV_RX", $sformatf("t=%0t drive %0d bits, cpb=%0d, data=%0b",
              $time, bits.size(), cfg.clks_per_bit, item.data), UVM_LOW)
    //@(vif.drv_if);
    foreach (bits[i]) begin
        vif.drv_if.u_rx <= bits[i];
        repeat (cfg.clks_per_bit) @(vif.drv_if);
    end
    vif.drv_if.u_rx <= 1'b1;
endtask

 function bit calc_parity(bit [8:0] d);
    bit x = ^d;
    return (cfg.parity_sel == UART_PAR_EVEN) ? x : ~x;
endfunction

function void build_frame (ref bit bits[$], uart_item item);
    int n_data;
    int n_stop;
    bit [8:0] d;
    bit p;

    n_data = (cfg.data_width == UART_DATA_9) ? 9 : 8;
    n_stop = (cfg.stop_bit_sel == UART_STOP_2) ? 2 : 1;
    d = item.data;  
    if (n_data == 8) d[8] = 1'b0;

    bits.delete();
    bits.push_back(1'b0);                     
    for (int i = 0; i < n_data; i++)
        bits.push_back(d[i]);  
                        // LSB first
    if (cfg.parity_sel != UART_PAR_NONE) begin  
        p = calc_parity(d);
        if (item.parity_error) p = ~p;          
        bits.push_back(p);
    end
    repeat (n_stop)
        bits.push_back(item.frame_error ? 1'b0 : 1'b1);
endfunction

endclass
