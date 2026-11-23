//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_tx_irq_seq (virtual sequence)
//-- Description    : TX interrupt for TXISEL = 00, 10, 01 (F2.4.4.1-3)
//-- History        : ver.1.00 (26/11/17) 1st release
//===========================================================================

class vsuart_tx_irq_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_irq_seq)

    uvm_event tx_ev;

    function new(string name = "vsuart_tx_irq_seq");
        super.new(name);
    endfunction

    task check_no_irq();
        check_field(ral.IFS.TXIFS, 0);
        check_irq(EV_TX_IRQ, 0);
    endtask

    task set_txisel(bit [1:0] txisel);
        ral.CR.TXISEL.set(txisel);
        update_reg(ral.CR);
        check_no_irq();
    endtask

    // wait TX IRQ, check STA.TISTA/TRSTA == exp_idle, clear TXIFS (W1C), check IRQ gone
    task wait_tx_irq(bit exp_idle);
        uvm_reg_data_t sta;
        tx_ev.wait_on();
        check_field(ral.IFS.TXIFS, 1);
        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.TISTA, exp_idle);
        expect_field(sta, ral.STA.TRSTA, exp_idle);
        clear_irq(ral.IFS.TXIFS);
        check_no_irq();
    endtask

    virtual task body();
        tx_ev = uvm_event_pool::get_global(EV_TX_IRQ);
        init_rst(13, 10000);
        config_default();

        //IRQ when a character moves to the shift register, none at end of frame
        set_txisel(2'b00);
        apb_wr_data();
        wait_tx_irq(1'b0);
        wait_field(ral.STA.TRSTA, 1);
        check_no_irq();

        //IRQ when TX FIFO becomes empty
        set_txisel(2'b10);
        apb_wr_data();
        wait_tx_irq(1'b0);
        repeat (2) apb_wr_data();
        wait_tx_irq(1'b0);
        wait_field(ral.STA.TRSTA, 1);
        check_no_irq();

        //TXISEL=01: IRQ after the stop bit of the last character (4 characters)
        set_txisel(2'b01);
        repeat (4) apb_wr_data();
        wait_tx_irq(1'b1);
        check_no_irq();
    endtask
endclass
