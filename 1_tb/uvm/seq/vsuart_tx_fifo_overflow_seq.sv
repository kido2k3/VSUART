//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_tx_fifo_overflow_seq (virtual sequence)
//-- History        : ver.1.00 (26/11/18) 1st release
//===========================================================================

class vsuart_tx_fifo_overflow_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_fifo_overflow_seq)

    function new(string name = "vsuart_tx_fifo_overflow_seq");
        super.new(name);
    endfunction

    virtual task config_default();
        int unsigned sys_hz = 112_000_000;
        if (ral == null) `uvm_fatal(get_type_name, "ral not connected")
        uart_disable();
        if (cfg != null) sys_hz = cfg.c_cfg._sys_freq * 1_000_000;

        ral.MODE.BSEL.set(1'b1);
        ral.MODE.PDSEL.set(2'b01);
        ral.MODE.SPSEL.set(1'b0);
        ral.CR.TXISEL.set(2'b11);
        ral.CR.RXISEL.set(2'b00);
        ral.BRG.BRG.set(16'((sys_hz + 4 * 9600 / 2) / (4 * 9600) - 1));
        ral.IE.TXTE.set(1'b1);
        ral.IE.RXTE.set(1'b1);
        ral.IE.ERRIE.set(1'b1);
        update_reg(ral.MODE);
        update_reg(ral.CR);
        update_reg(ral.BRG);
        update_reg(ral.IE);

        if (cfg != null) begin
            cfg.u_cfg.data_width   = UART_DATA_8;
            cfg.u_cfg.parity_sel   = UART_PAR_ODD;
            cfg.u_cfg.stop_bit_sel = UART_STOP_1;
            cfg.u_cfg.baudrate     = 9600;
            cfg.u_cfg.clks_per_bit_cal();
            uvm_config_db #(vsuart_cfg) :: set (null, "*", "cfg", cfg);
            `uvm_info("updated_cfg", $sformatf("Update new configure to:\n%s", cfg.sprint), UVM_LOW)
        end

        uart_enable();

    endtask

    virtual task body();
        init_rst(13, 10000);
        // select
        // configure registers then uart enable
        config_default();
        // write 130 frames
        repeat(130) begin
            apb_wr_data();
        end
        // check TXIFS=1
        check_field(ral.IFS.TXIFS, 1);
        // clear TXIFS
        clear_irq(ral.IFS.TXIFS);
    endtask
endclass
