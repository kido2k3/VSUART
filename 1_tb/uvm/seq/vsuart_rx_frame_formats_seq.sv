//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_rx_frame_formats_seq (UART configuration flow)
//-- History        : ver.1.00 (26/10/24) 1st release
//===========================================================================

class vsuart_rx_frame_formats_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_frame_formats_seq)
    
    function new(string name = "vsuart_rx_frame_formats_seq");
        super.new(name);
    endfunction
    
    task single_format_transfer();
        //Configure the UART agent, then the registers from it
        if (!cfg.u_cfg.randomize() with {
            baudrate == baud;
        })
            `uvm_fatal(get_type_name, "uart_cfg randomize failed")
        else begin
            `uvm_info("updated_cfg", $sformatf("Update new configure to:\n%s", cfg.sprint), UVM_LOW)
            uvm_config_db #(vsuart_cfg) :: set (null, "*", "cfg", cfg);
        end
        config_datamode(cfg.u_cfg);
        // write uart data
        uart_wdata();
        // wait RX fifo
        wait_rx_fifo_not_empty();
        // read RX fifo
        apb_rd_data();
    endtask
    
    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        // init reset
        init_rst(13, 10000);
        config_default();
        repeat(seq_len) single_format_transfer();
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
