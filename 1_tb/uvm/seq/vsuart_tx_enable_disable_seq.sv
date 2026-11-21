//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_tx_enable_disable_seq (virtual sequence)
//-- Description    : UEN[0]=0 aborts TX and clears TX FIFO (F2.4.2.4)
//-- History        : ver.1.00 (26/11/17) 1st release
//===========================================================================

class vsuart_tx_enable_disable_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_enable_disable_seq)

    rand int unsigned n_char;   // characters in TX FIFO before the abort
    constraint c_n_char { n_char inside {[1:`FIFO_DEPTH]}; }

    function new(string name = "vsuart_tx_enable_disable_seq");
        super.new(name);
    endfunction

    // TX idle, shift register and TX FIFO empty
    task check_tx_empty();
        uvm_reg_data_t sta;
        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.TISTA, 1);
        expect_field(sta, ral.STA.TRSTA, 1);
        expect_field(sta, ral.STA.TBSTA, 0);
    endtask

    virtual task body();
        if (!randomize(n_char)) `uvm_fatal("TX_EN_DIS", "n_char randomization failed")

        init_rst(13, 10000);
        config_default();

        // 1. fill TX FIFO, abort while the first character is on the line
        repeat (n_char) apb_wr_data();
        wait_field(ral.STA.TISTA, 0);

        // 2. UEN[0] = 0: abort + clear TX FIFO
        uart_enable(3'b110);
        wait_field(ral.STA.TISTA, 1);
        check_tx_empty();

        // 3. write while UEN[0] = 0 is ignored
        apb_wr_data();
        check_tx_empty();

        // 4. re-enable: nothing left to send
        uart_enable(3'b111);
        check_tx_empty();

        // 5. only the characters written after re-enable go out (scoreboard compares them)
        repeat (n_char) apb_wr_data();
    endtask
endclass
