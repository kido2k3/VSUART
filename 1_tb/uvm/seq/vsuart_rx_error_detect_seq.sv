//===========================================================================
//-- Author         : 
//-- Name           : vsuart_rx_error_detect_seq (virtual sequence)
//-- Description    : Framing / parity error detection and read-to-clear
//--                  Case 0: parity error only        -> PRERR=1, FRERR=0
//--                  Case 1: framing error only       -> PRERR=0, FRERR=1
//--                  Case 2: parity + framing error   -> PRERR=1, FRERR=1
//-- History        : ver.1.00 (26/11/25) 1st release
//===========================================================================
class vsuart_rx_error_detect_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_rx_error_detect_seq)

    function new(string name = "vsuart_rx_error_detect_seq");
        super.new(name);
    endfunction

    task err_case(string tag, bit par_err, bit frm_err);
        uvm_reg_data_t sta;
        uvm_event      ev_err = uvm_event_pool::get_global(EV_ERR_IRQ);

        `uvm_info(get_type_name, $sformatf("[%s] parity_error=%0b frame_error=%0b",
                  tag, par_err, frm_err), UVM_LOW)

        uart_wdata(par_err, frm_err);
        ev_err.wait_on();   // a hang here is caught by the run_phase timeout

        // IRQ is raised and ERRIFS is set before STA is read (IFS is W1C)
        check_irq(EV_ERR_IRQ, 1);
        check_field(ral.IFS.ERRIFS, 1);

        // 1st STA read: error bits set; 2nd STA read: cleared (read-to-clear)
        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.PRERR, par_err);
        expect_field(sta, ral.STA.FRERR, frm_err);
        read_reg(ral.STA, sta);
        expect_field(sta, ral.STA.PRERR, 0);
        expect_field(sta, ral.STA.FRERR, 0);

        // ERRIFS / irq stay 1 after STA reads, until cleared by W1C
        check_field(ral.IFS.ERRIFS, 1);
        check_irq(EV_ERR_IRQ, 1);
        clear_irq(ral.IFS.ERRIFS);
        check_field(ral.IFS.ERRIFS, 0);
        check_irq(EV_ERR_IRQ, 0);
    endtask

    virtual task body();
        if (cfg == null || ral == null)
            `uvm_fatal("ERRFLAG_SETUP", "cfg/ral not connected")
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)

        init_rst(13, 10000);
        config_default();
        check_field(ral.IE.ERRIE, 1);
        err_case("parity",       1'b1, 1'b0);
        err_case("framing",      1'b0, 1'b1);
        err_case("parity_frame", 1'b1, 1'b1);

        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass