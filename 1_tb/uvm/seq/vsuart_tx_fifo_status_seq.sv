//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_tx_fifo_status_seq (virtual sequence)
//-- History        : ver.1.00 (26/11/18) 1st release
//===========================================================================

class vsuart_tx_fifo_status_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_tx_fifo_status_seq)

    function new(string name = "vsuart_tx_fifo_status_seq");
        super.new(name);
    endfunction


    virtual task body();
        init_rst(13, 10000);
        // configure registers then uart enable
        config_default();
        // write 128 frames
        repeat(128) begin
            apb_wr_data();
        end
        // check TBSTA, TISTA, TRSTA
        check_field(ral.STA.TBSTA, 0);
        check_field(ral.STA.TISTA, 0);
        check_field(ral.STA.TRSTA, 0);
        // write 129th frame
        apb_wr_data();
        // check TBSTA, TISTA, TRSTA
        check_field(ral.STA.TBSTA, 1);
        check_field(ral.STA.TISTA, 0);
        check_field(ral.STA.TRSTA, 0);
        // wait for TBSTA=0
        wait_field(ral.STA.TBSTA, 0);
        // wait for TISTA=1
        wait_field(ral.STA.TISTA, 1);
        // check TBSTA, TISTA, TRSTA
        check_field(ral.STA.TBSTA, 0);
        check_field(ral.STA.TISTA, 1);
        check_field(ral.STA.TRSTA, 1);
        
    endtask
endclass
