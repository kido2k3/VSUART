//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_rx_irq_seq (virtual sequence)
//-- History        : ver.1.00 (26/11/21) 1st release
//===========================================================================

class vsuart_rx_irq_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_irq_seq)

    function new(string name = "vsuart_rx_irq_seq");
        super.new(name);
    endfunction
    
    // task: check interrupt triggered -> clear -> check interrupt not-triggered
    task rxifs_check;
        `uvm_info("SEQ", "check interrupt rx field is triggered", UVM_LOW)
        check_field(ral.IFS.RXIFS, 1);
        check_irq(EV_RX_IRQ, 1);
        `uvm_info("SEQ", "clear irq", UVM_LOW)
        clear_irq(ral.IFS.RXIFS);
        check_field(ral.IFS.RXIFS, 0);
        check_irq(EV_RX_IRQ, 0);
    endtask

    virtual task body();
        init_rst(13, 10000);
        `uvm_info("SEQ", "configure registers, RXISEL='b00 then uart enable", UVM_LOW)
        config_default();
        
        `uvm_info("SEQ", "transfer RX data", UVM_LOW)
        uart_wdata();
        `uvm_info("SEQ", "wait for data transferred into fifo", UVM_LOW)
        wait_rx_fifo_not_empty();
        apb_rd_data();
        rxifs_check();
        
        `uvm_info("SEQ", "change RXISEL to 'b01", UVM_LOW)
        ral.CR.RXISEL.write(status, 2'b01);
        `uvm_info("SEQ", "transfer RX data", UVM_LOW)
        uart_wdata();
        `uvm_info("SEQ", "wait for data transferred into fifo", UVM_LOW)
        wait_rx_fifo_not_empty();
        apb_rd_data();
        rxifs_check();
        
        `uvm_info("SEQ", "change RXISEL to 'b10", UVM_LOW)
        ral.CR.RXISEL.write(status, 2'b10);
        `uvm_info("SEQ", "transfer RX data, but not trigger interrupt yet", UVM_LOW)
        repeat(`FIFO_DEPTH*3.0/4 - 1) begin
            uart_wdata();
        end
        check_field(ral.IFS.RXIFS, 0);
        `uvm_info("SEQ", "transfer RX data, but trigger interrupt", UVM_LOW)
        uart_wdata();
        repeat(`FIFO_DEPTH*3.0/4) begin
            apb_rd_data();
        end
        rxifs_check();
    endtask
endclass
