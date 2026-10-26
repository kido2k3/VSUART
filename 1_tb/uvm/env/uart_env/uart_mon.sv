//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_mon (uart monitor)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================
class uart_mon extends uvm_monitor;
 `uvm_component_utils(uart_mon)

 virtual uart_if vif;
 uart_cfg cfg ;
 // port to scoreboard
 int unsigned n_rx_frames; 
 int unsigned n_tx_frames; 

 uvm_analysis_port #(uart_item) as_tx_port;
 uvm_analysis_port #(uart_item) as_rx_port;

 function new (string name, uvm_component parent);
    super.new (name, parent);
 endfunction

 // build phase: get vif
 virtual function void build_phase (uvm_phase phase);
    `uvm_info("build_phase", "Entered...", UVM_LOW)
    super.build_phase (phase);

    // create here
    as_tx_port = new ("as_tx_port", this);
    as_rx_port = new ("as_rx_port", this);

    // get vif
    if (! uvm_config_db #(virtual uart_if) :: get (this, "", "uart_vif", vif)) begin 
        `uvm_fatal ("NOT_IF", "interface not found")
     end

    // get cfg
    if (! uvm_config_db #(uart_cfg) :: get (this, "", "uart_cfg", cfg)) begin
        `uvm_fatal ("NOT_CFG", "UART configured not found")
     end
    `uvm_info("build_phase", "Exit...", UVM_LOW)
 endfunction

 // run phase
 virtual task run_phase (uvm_phase phase);
    forever begin
        wait(vif.rst_n === 1'b1);// wait till reset deassert
        fork begin : mon_threads 
            fork
                tx_flow();
                rx_flow();
                wait(vif.rst_n === 1'b0);// wait untill reset assert the exit
            join_any
            disable fork;// kill both tx_flow and rx_flow to clear the status
        end join
        end
 endtask

 // distinguish tx and rx
 function get_tx_rx (bit dir);
    return dir ? vif.mon_if.u_tx : vif.mon_if.u_rx;// if dir == 1 -> tx otherwise rx
 endfunction

 // tx flow: monitor and check in tx pin
 task tx_flow;
    uart_item tx_item;
    `uvm_info("MON_START", $sformatf("tx_flow started at %0t", $time), UVM_LOW)
    forever begin
         tx_item = uart_item::type_id::create("tx_item");// create object "tx_item"
        collect_frame(1'b1, tx_item);// regulate tx_item
        `uvm_info("MON_TX", tx_item.sprint, UVM_LOW)
         n_tx_frames++;
        as_tx_port.write(tx_item);// send to scoreboard
    end
 endtask

 // rx flow: monitor and check in rx pin
 task rx_flow;
    uart_item rx_item;
    `uvm_info("MON_START", $sformatf("rx_flow started at %0t", $time), UVM_LOW)
    forever begin
        rx_item = uart_item::type_id::create("rx_item");// create object "rx_item"
        collect_frame(1'b0, rx_item);// regulate rx_item
        `uvm_info("MON_RX", rx_item.sprint, UVM_LOW)
        n_rx_frames++;
         as_rx_port.write(rx_item);// send to scoreboard
    end
 endtask

 task collect_frame (bit dir , uart_item item);
    int cpb, n_data, n_stop;
    bit [8:0] d;
    bit par_bit, exp_par;
    bit has_par;
    //--------step 1st : wait for start bit-------- //
    while (get_tx_rx(dir) !== 1'b1) @(vif.mon_if); //IDLE
    if (! uvm_config_db #(uart_cfg) :: get (this, "", "uart_cfg", cfg)) begin
        `uvm_fatal ("NOT_CFG", "UART configured not found")
     end
    while (get_tx_rx(dir) !== 1'b0) @(vif.mon_if); // START
        item.start_time = $time ; //start time

//---------------step 2nd : write the configuaration when saw start bit ---------
    cpb     = cfg.clks_per_bit;
    n_data  = (cfg.data_width   == UART_DATA_9)  ? 9 : 8;
    n_stop  = (cfg.stop_bit_sel == UART_STOP_2)  ? 2 : 1;
    has_par = (cfg.parity_sel   != UART_PAR_NONE);
    if (cpb < 2)
        `uvm_fatal("MON_CFG", $sformatf("clks_per_bit=%0d, cfg not yet calculated (if_clk_freq=%0d baud=%0d)",
                                        cpb, cfg.if_clk_freq, cfg.baudrate))

    //--------step 3rd : wait for middle of the start bit--------
    repeat (cpb/2) @(vif.mon_if); // come to the middle of the start bit
    if (get_tx_rx(dir) !== 1'b0) // if still not become 0 then warning
        `uvm_warning("MON_STA","Start bit has been glitch")

    //--------step 4th read data bit (LSb first)--------
    for (int i = 0; i < n_data; i++)begin
        repeat (cpb) @(vif.mon_if);
        d[i] = get_tx_rx(dir);
    end

    //--------step 5th check the parity--------
    item.parity_error = 0 ;
    if (has_par) begin
        repeat(cpb)@(vif.mon_if);
        par_bit = get_tx_rx(dir);
        exp_par = (cfg.parity_sel == UART_PAR_EVEN) ? (^d) : (~^d);
        if (par_bit !== exp_par) item.parity_error = 1;
    end
//     else item.parity = UART_PAR_NONE ;

    //--------step 6th check the stop bit--------
    item.frame_error = 0 ;
    repeat(n_stop)begin
        repeat(cpb)@(vif.mon_if);
        if(get_tx_rx(dir) !== 1'b1) item.frame_error = 1;
    end

    //--------step 7th rewrite item--------
    item.data = d;
    //item.parity = par_bit ? UART_PAR_EVEN : UART_PAR_ODD ;
    item.end_time = $time ;
 endtask
endclass
