//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_apb_reset_seq
//-- Description    : Scenario 2: APB reset while idle and during ACCESS phase
//-- History        : ver.1.00 (26/11/06
//===========================================================================

class vsuart_apb_reset_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_apb_reset_seq)

    function new(string name = "vsuart_apb_reset_seq");
        super.new(name);
    endfunction

    virtual task body();
        int pclk_cyc = 10_000 / cfg.c_cfg._apb_freq;

        init_rst(13, 10000);
        config_default();

        //APB reset while bus is idle: UART core remains enabled
        apb_rst(pclk_cyc / 2, 10 * pclk_cyc);
        check_field(ral.MODE.UEN, 3'b111);

        //APB reset during ACCESS phase of a BRG write (PRS is reserved/RO since spec v0.05)
        uart_disable();
        fork
            begin
                ral.BRG.write(status, $urandom_range(65535, 1), .parent(this));
                if (status == UVM_IS_OK)
                    `uvm_error("APB_RESET_ABORT", "Interrupted BRG write unexpectedly completed")
            end
            apb_rst(2 * pclk_cyc, 10 * pclk_cyc); // Assert PRESETn in ACCESS phase
        join


        //Write new random value and verify readback
        assert(ral.BRG.randomize());
        update_reg(ral.BRG);
        check_field(ral.BRG.BRG, ral.BRG.BRG.get());
        uart_enable();
    endtask
endclass
