//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_reset_value_seq
//-- Description    : Scenario 1: global reset values and output pins
//-- History        : ver.1.00 (26/11/06) Test-plan implementation
//===========================================================================

class vsuart_reset_value_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_reset_value_seq)

    function new(string name = "vsuart_reset_value_seq");
        super.new(name);
    endfunction


    virtual task body();
        init_rst(13, 10000);

        // Start TX & RX full duplex, then assert global reset mid-transfer
        config_default();
        apb_wr_data();
        fork
            uart_wdata();
            operate_rst(2_000_000, 12_000_000);
        join

    endtask
endclass
