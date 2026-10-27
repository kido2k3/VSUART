// TX format sweep using section 6 Default Register setup.
class vsuart_tx_frame_formats_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_frame_formats_seq)

    function new(string name = "vsuart_tx_frame_formats_seq");
        super.new(name);
    endfunction

    // Check TX done through TRSTA = 1 when the transmitter is idle.
    task wait_tx_done();
        uvm_reg_data_t mode_value;
        //check TRSTA = 0 to make sure transmit occur 
        for (int idle = 0; idle <= 1; idle++) begin
            do begin
                // Work around the current RTL retaining STA status while
                // PADDR stays on STA: select a harmless register first so
                // live status can refresh before the next STA read.
                ral.MODE.read(status, mode_value, .parent(this));
                if (status != UVM_IS_OK)
                    `uvm_fatal("TX_STATUS", "Cannot read MODE before polling STA")
                ral.STA.read(status, value, .parent(this));
                value = (value >> 1) & 1;
                if (status != UVM_IS_OK)
                    `uvm_fatal("TX_STATUS", "Cannot read TX completion status")
                if (value != idle) #1us;
            end while (value != idle);
        end
    endtask

    task run_formats();
        //Use to display the mode for debugging
        string names[8] = '{"8N1", "8N2", "8E1", "8E2", "8O1", "8O2", "9N1", "9N2"};
        
        int mode_order[8] = '{0, 1, 2, 3, 4, 5, 6, 7};
        
        // Shuffle order for random mode.
        mode_order.shuffle();
        `uvm_info("TX_MODE_ORDER", $sformatf("Mode order: %p", mode_order), UVM_LOW)
        init_rst(13, 10000);
        config_default();
        foreach (mode_order[i]) begin
            int f;
            f = mode_order[i];
            uart_disable();
            check_uen_disabled();
            cfg.u_cfg.data_width = (f >= 6) ? UART_DATA_9 : UART_DATA_8;
            case (f / 2)
                1: cfg.u_cfg.parity_sel = UART_PAR_EVEN;
                2: cfg.u_cfg.parity_sel = UART_PAR_ODD;
                default: cfg.u_cfg.parity_sel = UART_PAR_NONE;
            endcase
            cfg.u_cfg.stop_bit_sel = (f % 2) ? UART_STOP_2 : UART_STOP_1;
            ral.MODE.PDSEL.set(pdsel_of(cfg.u_cfg));
            ral.MODE.SPSEL.set(f % 2);
            update_reg(ral.MODE);
            uart_enable(3'b111);
            `uvm_info("TX_FORMAT_manhndd", {"Sending ", names[f]}, UVM_LOW)
            apb_wr_data();
            wait_tx_done();
        end
        `uvm_info("TX_FORMATS_DONE", "Sent one random character per format across all 8 formats", UVM_LOW)
    endtask

    virtual task body();
        if (cfg == null || ral == null)
            `uvm_fatal("TX_CFG", "cfg/ral not connected")

        fork
            begin
                fork
                    run_formats();
                    begin
                        // Eight frames at 9600 baud need about 9 ms.
                        #20ms;
                        `uvm_fatal("TX_TIMEOUT", "TX format sweep timed out")
                    end
                join_any
                disable fork;
            end
        join
    endtask
endclass
