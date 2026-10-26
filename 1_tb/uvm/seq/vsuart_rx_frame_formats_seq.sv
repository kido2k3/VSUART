//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_rx_frame_formats_seq (UART configuration flow)
//-- History        : ver.1.00 (26/10/24) 1st release
//===========================================================================

class vsuart_rx_frame_formats_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_frame_formats_seq)

    int unsigned baud = 112500;

    function new(string name = "vsuart_rx_frame_formats_seq");
        super.new(name);
    endfunction
    
    task single_format_transfer(
        uart_par_e par_mode = UART_PAR_EVEN, 
        uart_stop_type_e stop_mode = UART_STOP_2, 
        uart_data_type_e data_mode = UART_DATA_8
    );
        // init reset
        init_rst(13, 10000);
        // disable uart
        uart_disable();

        //Configure the UART agent, then the registers from it
        if (!cfg.u_cfg.randomize() with {
            baudrate == baud;
            parity_sel == par_mode;
            stop_bit_sel == stop_mode;
            data_width == data_mode;
        })
            `uvm_fatal(get_type_name, "uart_cfg randomize failed")
        else begin
            `uvm_info("updated_cfg", $sformatf("Update new configure to:\n%s", cfg.sprint), UVM_LOW)
            uvm_config_db #(vsuart_cfg) :: set (null, "*", "cfg", cfg);
        end
        configure(cfg.u_cfg);
        // enable uart
        uart_enable();
        ral.MODE.UEN.read(status, value, .parent(this));
        // write uart data
        uart_wdata();
        do begin
            // wait until read fifo having data
            ral.STA.RBDSTA.read(status, value, .parent(this));
        end while (value == 0);
        // read RX fifo
        apb_rd_data();
    endtask
    
    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        single_format_transfer();
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
