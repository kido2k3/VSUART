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
    // get virtual interface from uvm_if
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", vif))begin
        `uvm_fatal("NO_IF","Virtual interface not found")
    end
    //get cfg from uvm_cfg
    if (!uvm_config_db#(uart_cfg)::get(this, "", "uart_cfg", cfg))begin
        `uvm_fatal("NO_CONFIG","Configured not found")
    end
    `uvm_info ("build phase","Exit....", UVM_LOW)

endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
    vif.drv_if.u_rx <= 1'b1; //IDLE
    wait (vif.rst_n === 1'b1) //wait till reset finish
    forever begin
        seq_item_port.get_next_item(req);// get item from sequencer
        `uvm_info("DRV", $sformatf("Starting to drive transaction:\n%s", req.sprint()), UVM_HIGH)
        if (req.uart_dir == UART_RX || req.uart_dir == UART_TX_RX) // only RX is transmit must regulate in sequence
            drive_item(req);
        else begin
            `uvm_warning("DRV_TX" , "item with uart_dir == UART_TX ignored (drive only rx)")
    end
   
    seq_item_port.item_done(); // call sequnecer current sequence is completed  
    end

endtask

//send one frame
task drive_item(uart_item item);
    bit bits[$];
    build_frame(bits, item);// insert the configurate
    @(vif.drv_if); //wait till posedge clk
    foreach (bits[i]) begin
        vif.drv_if.u_rx <= bits[i]; //connect with u_rx
        repeat (cfg.clks_per_bit) @(vif.drv_if);// send each bit sync with the clock ,still not quite right
    end
    vif.drv_if.u_rx <= 1'b1; // return to IDLE 
endtask

//function bit [8:0] valid_data(bit data_type)
// if (data_type) return data ; // 9bit -> data
// else return {1'b0 , data[7:0]}; // 8bit -> data[8]=0
// endfunction

 function bit calc_parity(bit [8:0] d); //
    bit x = ^d; //parity odd or even 
    return (cfg.parity_sel == UART_PAR_EVEN) ? x : ~x; //configuarate the parity Even or Odd
 endfunction

 function void build_frame (ref bit bits[$], uart_item item);
    uart_item t;
    int n_data = (cfg.data_width == UART_DATA_9) ? 9 : 8;
    int n_stop = (cfg.stop_bit_sel == UART_STOP_2) ? 2 : 1;
    bit d = (n_data == 9) ? item.data : {1'b0, item.data[7:0]};
    bit p;

    bits.delete();
    bits.push_back(1'b0); //start bits
    for (int i = 0; i< n_data; i++) // configurate 9 bit or 8 bit
        bits.push_back(item.data[i]); //LSB first push data randomly
    if (item.parity != UART_PAR_NONE) begin
        p = calc_parity(d);
        if (item.parity_error) p = ~p ; //generate parity error
            bits.push_back(p); //if no generate error the parity will push into the data
    end
    
    repeat (n_stop)// the amount of the stop bit
        bits.push_back(item.frame_error ? 1'b0 : 1'b1); //stop bits go wrong -> test framing
    endfunction

endclass