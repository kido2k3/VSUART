//===========================================================================
//-- Author : Trizrd
//-- Name : uart_agent
//-- History : ver.1.00 (26/10/17) 1st release
//-- :
//===========================================================================

class uart_agent extends uvm_agent;
 `uvm_component_utils(uart_agent)

 uart_sequencer sqr;
 uart_drv drv;
 uart_mon mon;

 uvm_analysis_port #(uart_item) as_tx_port;
 uvm_analysis_port #(uart_item) as_rx_port;

 function new(string name = "uart_agent", uvm_component parent) ;
    super.new(name, parent);
 endfunction

 function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("build_phase", "Entered...", UVM_LOW)
    as_tx_port = new ("as_tx_port", this);
    as_rx_port = new ("as_rx_port", this);

    if (get_is_active() == UVM_ACTIVE) begin
        sqr = uart_sequencer::type_id::create("sqr", this);
        drv = uart_drv::type_id::create("drv", this);
    end
    mon = uart_mon::type_id::create("mon", this);
    //maybe add coverage for later
     `uvm_info("build_phase", "Exit.....", UVM_LOW)
 endfunction

 function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("connect_phase", "Entered...", UVM_LOW)
    if (get_is_active() == UVM_ACTIVE)
        drv.seq_item_port.connect(sqr.seq_item_export);

    mon.as_tx_port.connect(as_tx_port);
    mon.as_rx_port.connect(as_rx_port);
    `uvm_info("connect_phase", "Exit..", UVM_LOW)
 endfunction

endclass