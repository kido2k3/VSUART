//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_tx_frame_formats_seq (virtual sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//===========================================================================

class vsuart_tx_frame_formats_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_frame_formats_seq)

    function new(string name = "vsuart_tx_frame_formats_seq");
        super.new(name);
    endfunction

    // Check TX done through TRSTA = 1 when the transmitter is idle.
    task wait_tx_done();
        int idle = 0;

        fork
            begin
                uvm_reg_data_t mode_value;

                //check TRSTA = 0 to make sure transmit occur and TRSTA = 1 to make sure transmiter is idle
                for (idle = 0; idle <= 1; idle++) begin
                    do begin
                        ral.STA.read(status, value, .parent(this));
                        value = (value >> 1) & 1;
                        if (status != UVM_IS_OK)
                            `uvm_fatal("TX_STATUS", "Cannot read TX completion status")
                    end while (value != idle);
                end
            end
            begin
                #3ms;
                `uvm_error("TX_STATUS", $sformatf("Timeout waiting for TRSTA=%0d", idle[0]))
            end
        join_any
        disable fork;
    endtask

    task single_format_transfer();
        // Configure the UART agent, then program the DUT from the same format.
        if (!cfg.u_cfg.randomize() with {
            baudrate == baud;
        })
            `uvm_fatal(get_type_name, "uart_cfg randomize failed")
        else begin
            `uvm_info("updated_cfg", $sformatf("Update new configure to:\n%s", cfg.sprint), UVM_LOW)
            uvm_config_db #(vsuart_cfg)::set(null, "*", "cfg", cfg);
        end
        config_datamode(cfg.u_cfg);
        // Write one character to TX FIFO and finish it before changing format.
        apb_wr_data();
        wait_tx_done();
    endtask

    virtual task body();
        if (cfg == null || ral == null)
            `uvm_fatal("TX_CFG", "cfg/ral not connected")
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        init_rst(13, 10000);
        config_default();
        repeat(seq_len) single_format_transfer();
        `uvm_info("TX_FORMATS_DONE", $sformatf("Completed %0d randomized TX frame-format transfers", seq_len), UVM_LOW)
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
