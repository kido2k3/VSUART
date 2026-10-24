//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_scb (vsuart scoreboard)
//-- History        : ver.1.00 (26/10/24) 1st release
//===========================================================================
`uvm_analysis_imp_decl(_apb_mst)
`uvm_analysis_imp_decl(_uart_tx)
`uvm_analysis_imp_decl(_uart_rx)
`uvm_analysis_imp_decl(_ifs)
`uvm_analysis_imp_decl(_rst)
class vsuart_scb extends uvm_scoreboard;

    `uvm_component_utils(vsuart_scb)
    // all analysis port
    uvm_analysis_imp_apb_mst #(_apb_item, vsuart_scb) apb_mst_ap_imp;
    uvm_analysis_imp_uart_tx #(uart_item, vsuart_scb) uart_tx_ap_imp;
    uvm_analysis_imp_uart_rx #(uart_item, vsuart_scb) uart_rx_ap_imp;
    uvm_analysis_imp_ifs #(ifs_item, vsuart_scb) ifs_ap_imp;
    uvm_analysis_imp_rst #(rst_item, vsuart_scb) rst_ap_imp;
    // queue of data
    mailbox #(_apb_item) mb_apb_data;
    mailbox #(uart_item) mb_uart_tx_data;
    mailbox #(uart_item) mb_uart_rx_data;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // create analysis port
        apb_mst_ap_imp = new("apb_mst_ap_imp", this);
        uart_tx_ap_imp = new("uart_tx_ap_imp", this);
        uart_rx_ap_imp = new("uart_rx_ap_imp", this);
        ifs_ap_imp = new("ifs_ap_imp", this);
        rst_ap_imp = new("rst_ap_imp", this);
        // create queue
        mb_apb_data = new();
        mb_uart_tx_data = new();
        mb_uart_rx_data = new();
    endfunction

    task run_phase(uvm_phase phase);
        fork
            data_cmp(phase);
        join
    endtask
    
    // task: get data from queue and compare
    task data_cmp(uvm_phase phase);
        _apb_item apb;
        uart_item uart;
        forever begin
            wait(mb_apb_data.num != 0 || mb_uart_rx_data.num != 0);
            phase.raise_objection(this);
            `uvm_info("SCB object", "raise object here", UVM_LOW)
            mb_apb_data.get(apb);
            if(apb.trans_type == _apb_item::WRITE) begin
                mb_uart_tx_data.get(uart);
            end else begin
                mb_uart_rx_data.get(uart);
            end
            // compare here
            //...

            phase.drop_objection(this);
            `uvm_info("SCB object", "drop object here", UVM_LOW)
        end
    endtask

    // function: handle data received from apb monitor
    virtual function void write_apb_mst(_apb_item rcv_item);
        `uvm_info("SCB apb mst", $sformatf("received data:%s", rcv_item.sprint), UVM_LOW)
        if(rcv_item.addr == 16'hffff) begin
            if(!mb_apb_data.try_put(rcv_item)) begin
                `uvm_warning("SCB apb mst", "Fail to put data into queue")
            end
        end else begin
        end
    endfunction

    // function: handle data received from uart TX monitor
    virtual function void write_uart_tx(uart_item rcv_item);
        `uvm_info("SCB uart tx", $sformatf("received data:%s", rcv_item.sprint), UVM_LOW)
        if(!mb_uart_tx_data.try_put(rcv_item)) begin
            `uvm_warning("SCB uart tx", "Fail to put data into queue")
        end
    endfunction

    // function: handle data received from uart RX monitor
    virtual function void write_uart_rx(uart_item rcv_item);
        `uvm_info("SCB uart rx", $sformatf("received data:%s", rcv_item.sprint), UVM_LOW)
        if(!mb_uart_rx_data.try_put(rcv_item)) begin
            `uvm_warning("SCB uart rx", "Fail to put data into queue")
        end
    endfunction

    // function: handle data received from ifs monitor
    virtual function void write_ifs(ifs_item rcv_item);
    endfunction

    // function: handle data received from clk_rst monitor
    virtual function void write_rst(rst_item rcv_item);
    endfunction
    
endclass
