//===========================================================================
//-- Author         : manhndd
//-- Name           : vsuart_rx_enable_disable_seq (virtual sequence)
//-- Description    : RX is ignored while UEN[1]=0 (F2.5.2.4)
//-- History        : ver.1.00 (26/11/23) 1st release
//===========================================================================

class vsuart_rx_enable_disable_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_enable_disable_seq)

    rand int unsigned n_char;   // frames sent on rx while UEN[1]=0
    constraint c_n_char { n_char inside {[2:5]}; }

    function new(string name = "vsuart_rx_enable_disable_seq");
        super.new(name);
    endfunction

    virtual task body();
        if (!randomize(n_char)) `uvm_fatal("RX_EN_DIS", "n_char randomization failed")

        init_rst(13, 10000);
        config_default();

        // 1. frames on rx; UEN[1]=0 written while receiving
        fork
            repeat (n_char) uart_wdata();
            begin
                wait_field(ral.STA.RBDSTA, 1);
                uart_enable(3'b101);
            end
        join

        // 2. nothing stored while UEN[1]=0
        check_field(ral.STA.RBDSTA, 0);

        // 3. re-enable RX: only the frame sent after this is received
        uart_enable(3'b111);
        uart_wdata();
        wait_rx_fifo_not_empty();
        apb_rd_data();             
        check_field(ral.STA.RBDSTA, 0);
    endtask
endclass
