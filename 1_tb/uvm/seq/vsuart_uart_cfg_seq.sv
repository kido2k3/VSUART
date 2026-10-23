//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_uart_cfg_seq (UART configuration flow)
//-- History        : ver.1.00 (26/10/22) 1st release
//===========================================================================

// Flow, with the tasks of vsuart_base_seq:
//   1. uart_disable()  : UEN = 0, MODE.BSEL/PDSEL/SPSEL, PRS, BRG become writable
//   2. u_cfg           : random frame format + baud -> clks_per_bit
//      configure(u_cfg): MODE/PRS/BRG programmed from u_cfg through the RAL
//   3. uart_enable()   : UEN = 111 (core, RX, TX)

class vsuart_uart_cfg_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_uart_cfg_seq)

    int unsigned baud = 115200;

    function new(string name = "vsuart_uart_cfg_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        if (u_cfg == null) `uvm_fatal(get_type_name, "u_cfg not connected")
        init_rst(13, 10000);

        uart_disable();

        //Configure the UART agent, then the registers from it
        if (!u_cfg.randomize() with {
                stop_bit_sel inside {UART_STOP_1, UART_STOP_2};
                data_width == UART_DATA_9 -> parity_sel == UART_PAR_NONE; })
            `uvm_fatal(get_type_name, "uart_cfg randomize failed")
        configure(u_cfg);

        // 3. enable the UART
        uart_enable();

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
