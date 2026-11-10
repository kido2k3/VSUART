//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_rx_fifo_full_overflow_seq
//-- History        : ver.1.00 (26/11/06) Test-plan implementation
//===========================================================================

class vsuart_rx_fifo_full_overflow_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_fifo_full_overflow_seq)

    function new(string name = "vsuart_rx_fifo_full_overflow_seq");
        super.new(name);
    endfunction

    // Read STA and IFS once each and check the RX FIFO status fields by name
    virtual task check_rx_status(bit rbdsta, bit rbosta, bit rxifs);
        uvm_reg_data_t sta, ifs;
        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.RBDSTA, rbdsta);
        expect_field(sta, ral.STA.RBOSTA, rbosta);
        read_reg(ral.IFS, ifs);
        expect_field(ifs, ral.IFS.RXIFS, rxifs);
    endtask

    virtual task body();
        init_rst(13, 10000);
        config_default();

        // Configure RXISEL = 2'b11 (interrupt when RX FIFO is full = 128 bytes)
        uart_disable();
        ral.CR.RXISEL.set(2'b11);
        update_reg(ral.CR);
        uart_enable();

        // 0 frames (empty)
        check_rx_status(.rbdsta(0), .rbosta(0), .rxifs(0));

        // 1st frame
        uart_wdata();
        check_rx_status(.rbdsta(1), .rbosta(0), .rxifs(0));

        // Next 126 frames (127 stored)
        repeat (126) uart_wdata();
        check_rx_status(.rbdsta(1), .rbosta(0), .rxifs(0));

        // 128th frame (FIFO full): RX interrupt raised
        uart_wdata();
        check_rx_status(.rbdsta(1), .rbosta(0), .rxifs(1));
        check_irq(EV_RX_IRQ, 1);

        // 129th frame (overflow): dropped, RBOSTA set (RC: cleared by this read)
        uart_wdata();
        check_rx_status(.rbdsta(1), .rbosta(1), .rxifs(1));

        // Read all 128 frames (scoreboard checks data in order)
        repeat (128) apb_rd_data();
        check_rx_status(.rbdsta(0), .rbosta(0), .rxifs(1));

        // Clear RXIFS (W1C)
        clear_irq(ral.IFS.RXIFS);
        check_rx_status(.rbdsta(0), .rbosta(0), .rxifs(0));
        check_irq(EV_RX_IRQ, 0);
    endtask
endclass
