//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_base_seq (virtual sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                : ver.1.01 (26/10/21) configure(), uart_enable(), uart_disable()
//--                :                     through the register model
//--                : ver.1.02 (26/11/3) add apb reset
//===========================================================================
class vsuart_base_seq extends uvm_sequence;
    `uvm_object_utils(vsuart_base_seq)

    clk_rst_seqr    r_seqr;
    apb_mst_seqr    a_seqr;
    uart_seqr       u_seqr;

    // register model (env.reg_env.ral) and vsuart configuration
    ral_blk        ral;
    vsuart_cfg     cfg;

    // sequence
    rst_base_seq r_seq;
    rand uart_base_seq uart_seq;
    rand apb_mst_wdata_seq apb_wdata_seq;
    rand apb_mst_rdata_seq apb_rdata_seq;
    
    // for reg access
    uvm_status_e status;
    uvm_reg_data_t value;

    // default baudrate
    int unsigned baud = 9600;
    // sequence length
    int unsigned seq_len = 50;
    function new(string name = "vsuart_base_seq");
        super.new(name);
        r_seq = rst_base_seq::type_id::create("r_seq");
        uart_seq = uart_base_seq::type_id::create("uart_seq");
        apb_wdata_seq = apb_mst_wdata_seq::type_id::create("apb_wdata_seq");
        apb_rdata_seq = apb_mst_rdata_seq::type_id::create("apb_rdata_seq");
    endfunction
    

    // Read a register and check against expected value
    virtual task check_reg(input uvm_reg rg, input uvm_reg_data_t expected);
        uvm_status_e   access_status;
        uvm_reg_data_t actual;
        rg.read(access_status, actual, .path(UVM_FRONTDOOR), .parent(this));
        if (access_status != UVM_IS_OK) begin
            `uvm_error("REG_READ", {rg.get_full_name(), " read failed"})
            return;
        end
        if (actual !== expected)
            `uvm_error("REG_CHECK", $sformatf("%s actual=0x%0h expected=0x%0h",
                       rg.get_full_name(), actual, expected))
    endtask

    // Frontdoor read of a register, returns the value seen on the bus
    virtual task read_reg(input uvm_reg rg, output uvm_reg_data_t val);
        uvm_status_e access_status;
        rg.read(access_status, val, .path(UVM_FRONTDOOR), .parent(this));
        if (access_status != UVM_IS_OK)
            `uvm_error("REG_READ", {rg.get_full_name(), " read failed"})
    endtask

    // Check a field against its bits in an already read register value
    virtual function void expect_field(input uvm_reg_data_t reg_val, input uvm_reg_field fld,
                                       input uvm_reg_data_t expected);
        uvm_reg_data_t actual;
        actual = (reg_val >> fld.get_lsb_pos()) & ((uvm_reg_data_t'(1) << fld.get_n_bits()) - 1);
        if (actual !== expected)
            `uvm_error("REG_CHECK", $sformatf("%s actual=0x%0h expected=0x%0h (reg_val=0x%0h)",
                       fld.get_full_name(), actual, expected, reg_val))
    endfunction

    // Read a single register field and check against expected value
    virtual task check_field(input uvm_reg_field fld, input uvm_reg_data_t expected);
        uvm_reg_data_t reg_val;
        if (fld == null) begin
            `uvm_error("REG_NULL", "Passed field is null")
            return;
        end
        read_reg(fld.get_parent(), reg_val);
        expect_field(reg_val, fld, expected);
    endtask

    // Poll register until masked bits match expected.   
    virtual task wait_reg_bits(input uvm_reg rg,
                               input uvm_reg_data_t expected,
                               input uvm_reg_data_t mask,
                               input time timeout = 3ms);
        uvm_status_e access_status;
        uvm_reg_data_t actual;
        fork
            begin
                fork
                    begin
                        do begin
                            rg.read(access_status, actual, .path(UVM_FRONTDOOR), .parent(this));
                            if (access_status != UVM_IS_OK)
                                `uvm_fatal("REG_READ", {rg.get_full_name(), " polling read failed"})
                            if (rg == ral.STA && (actual & 'h58) !== 0)
                                `uvm_error("STA_ERROR", $sformatf("STA error bits sampled during polling: 0x%0h", actual))
                        end while ((actual & mask) !== (expected & mask));
                    end
                    begin
                        #(timeout);
                        `uvm_fatal("REG_TIMEOUT", $sformatf("%s expected=0x%0h mask=0x%0h last=0x%0h",
                                   rg.get_full_name(), expected, mask, actual))
                    end
                join_any
                disable fork;
            end
        join
    endtask

    // Poll a specific register field until it matches expected.
    virtual task wait_field(input uvm_reg_field fld,
                            input uvm_reg_data_t expected,
                            input time timeout = 3ms);
        uvm_reg_data_t mask = ((1 << fld.get_n_bits()) - 1) << fld.get_lsb_pos();
        wait_reg_bits(fld.get_parent(), expected << fld.get_lsb_pos(), mask, timeout);
    endtask

    // task: wait for rx fifo have data
    virtual task wait_rx_fifo_not_empty();
        wait_field(ral.STA.RBDSTA, 1);
    endtask


    // Clear an interrupt flag field in IFS (W1C).
    virtual task clear_irq(input uvm_reg_field fld);
        uvm_status_e access_status;
        ral.IFS.write(access_status, uvm_reg_data_t'(1) << fld.get_lsb_pos(), .path(UVM_FRONTDOOR), .parent(this));
        if (access_status != UVM_IS_OK)
            `uvm_error("IRQ_CLEAR", {fld.get_full_name(), " W1C clear failed"})
    endtask

    // Check interrupt state via global uvm_event_pool (EV_TX_IRQ, EV_RX_IRQ, EV_ERR_IRQ).
    virtual function void check_irq(string ev_name, bit expected);
        uvm_event ev = uvm_event_pool::get_global(ev_name);
        if (ev.is_on() !== expected)
            `uvm_error("IRQ_CHECK", $sformatf("%s actual=%0b expected=%0b", ev_name, ev.is_on(), expected))
    endfunction

    // Read one RX FIFO entry into actual and check the APB response.
    // Set expected_slverr=1 for a expected empty-FIFO read.
    virtual task read_rx_data(output uvm_reg_data_t actual,
                              input bit expected_slverr = 0);
        apb_mst_rdata_seq rd;
        rd = apb_mst_rdata_seq::type_id::create("rd");
        if (!rd.randomize()) `uvm_fatal("RX_READ", "Read sequence randomization failed")
        rd.start(a_seqr, this);
        actual = rd.rsp.data;
        if (rd.rsp.status != UVM_TLM_OK_RESPONSE || rd.rsp.slverr != expected_slverr)
            `uvm_error("RX_READ", $sformatf("RX read status=%s PSLVERR=%b expected=%b",
                       rd.rsp.status.name(), rd.rsp.slverr, expected_slverr))
    endtask

    // task: write data into dut rx
    virtual task uart_wdata();
        assert(uart_seq.randomize() with {});
        uart_seq.start(u_seqr);
    endtask

    // task: apb master read data
    virtual task apb_rd_data();
        uvm_reg_data_t actual;
        read_rx_data(actual);
    endtask

    // task: apb master write data
    virtual task apb_wr_data();
        assert(apb_wdata_seq.randomize());
        apb_wdata_seq.start(a_seqr);
    endtask

    // task: during operating reset
    virtual task operate_rst(int interval_time = 8, int rst_time = 60);
        r_seq.req.interval_time = interval_time;
        r_seq.req.rst_time = rst_time;
        r_seq.req.rst_type = rst_item::NO_CLK_PENDING;
        r_seq.start(r_seqr);
    endtask

    // task: initial reset
    virtual task init_rst(int interval_time = 8, int rst_time = 60);
        r_seq.req.interval_time = interval_time;
        r_seq.req.rst_time = rst_time;
        r_seq.req.rst_type = rst_item::CLK_PENDING;
        r_seq.start(r_seqr);
    endtask

    // task: apb reset
    virtual task apb_rst(int interval_time = 8, int rst_time = 60);
        r_seq.req.interval_time = interval_time;
        r_seq.req.rst_time = rst_time;
        r_seq.req.rst_type = rst_item::APB_RST;
        r_seq.start(r_seqr);
    endtask

    // task: write rg if its desired value differs from the mirror
    virtual task update_reg(uvm_reg rg);
        uvm_status_e access_status;
        rg.update(access_status, .parent(this));
        if (access_status != UVM_IS_OK) `uvm_error(get_type_name, {rg.get_name(), " update failed"})
    endtask


    // task: program the frame format and baud rate of cfg into the registers
    //   MODE.PDSEL <- data_width + parity_sel, MODE.SPSEL <- stop_bit_sel
    //   MODE.BSEL, PRS, BRG <- baudrate and cfg.c_cfg sys_clk (see find_divisors)
    // These fields are write-protected while the UART is enabled, so the UART is
    // disabled first.
    virtual task configure(uart_cfg cfg);
        bit        bsel;
        bit [3:0]  prs;
        bit [15:0] brg;
        int unsigned cpb, actual, actual_baud, sys_hz;
        if (ral == null) `uvm_fatal(get_type_name, "ral not connected")
        if (this.cfg == null) `uvm_fatal(get_type_name, "cfg not connected")
        check_uen_disabled();

        // sys_clk frequency in Hz, from the clock configuration
        sys_hz = this.cfg.c_cfg._sys_freq * 1_000_000;
        // sys_clk cycles per bit for the requested baud rate, rounded
        cpb = (sys_hz + cfg.baudrate / 2) / cfg.baudrate;

        void'(find_divisors(cpb, bsel, prs, brg));
        actual      = bit_time(bsel, prs, brg);
        actual_baud = (sys_hz + actual / 2) / actual;
        if (actual_baud != cfg.baudrate) begin
            // no exact divisors: the DUT runs at the closest baud rate, so the
            // UART agent (same cfg) is moved to it as well
            `uvm_info(get_type_name, $sformatf("baudrate=%0d not reachable, closest %0d (deviation %0.3f%%)",
                      cfg.baudrate, actual_baud, 100.0 * (real'(actual_baud) - real'(cfg.baudrate)) / cfg.baudrate), UVM_LOW)
        end
        ral.MODE.BSEL.set(bsel);
        ral.MODE.PDSEL.set(pdsel_of(cfg));
        ral.MODE.SPSEL.set(cfg.stop_bit_sel == UART_STOP_2);
        ral.PRS.PRS.set(prs);
        ral.BRG.BRG.set(brg);
        update_reg(ral.MODE);
        update_reg(ral.PRS);
        update_reg(ral.BRG);


        `uvm_info(get_type_name, $sformatf("configured: BSEL=%0d PRS=%0d BRG=%0d PDSEL=%b SPSEL=%0d (baudrate=%0d)",
                  bsel, prs, brg, 2'(ral.MODE.PDSEL.get()), ral.MODE.SPSEL.get(), cfg.baudrate), UVM_MEDIUM)
    endtask

    // task: MODE.UEN = uen (bit 0 TX, bit 1 RX, bit 2 core). Only byte 0 is
    // written (PSTRB=0001): UEN is individually accessible and never protected,
    // whereas a full MODE write is rejected (PSLVERR) while the UART is enabled.
    virtual task uart_enable(bit [2:0] uen = 3'b111);
        uvm_status_e status;
        if (ral == null) `uvm_fatal(get_type_name, "ral not connected")
        ral.MODE.UEN.set(uen);
        ral.MODE.UEN.write(status, ral.MODE.UEN.get(), .parent(this));
        if (status != UVM_IS_OK) `uvm_error(get_type_name, $sformatf("UEN=%b write failed", uen))
    endtask

    // task: UEN = 0, the protected fields become writable
    virtual task uart_disable();
        uart_enable(3'b000);
    endtask

    // task: disable the UART and read MODE.UEN back from the DUT to make sure
    // it is 0 before the protected fields (MODE, PRS, BRG, ...) are written
    virtual task check_uen_disabled();
        if (ral == null) `uvm_fatal(get_type_name, "ral not connected")
        check_field(ral.MODE.UEN, 3'b000);
    endtask

    // task: default register setting
    //   MODE: BSEL=1 (4x), PDSEL=01 (8-bit odd), SPSEL=0 (1 stop)
    //   CR  : TXISEL=00, RXISEL=00 (interrupt per character)
    //   PRS=1, BRG=728 (9600 bps), IE: TXTE=RXTE=ERRIE=1
    // The UART agent (cfg.u_cfg) gets the same format in base_test::set_default_uart_cfg()
    virtual task config_default();
        if (ral == null) `uvm_fatal(get_type_name, "ral not connected")
        uart_disable();

        ral.MODE.BSEL.set(1'b1);
        ral.MODE.PDSEL.set(2'b01);
        ral.MODE.SPSEL.set(1'b0);
        ral.CR.TXISEL.set(2'b00);
        ral.CR.RXISEL.set(2'b00);
        ral.PRS.PRS.set(4'd1);
        ral.BRG.BRG.set(16'd728);
        ral.IE.TXTE.set(1'b1);
        ral.IE.RXTE.set(1'b1);
        ral.IE.ERRIE.set(1'b1);
        update_reg(ral.MODE);
        update_reg(ral.CR);
        update_reg(ral.PRS);
        update_reg(ral.BRG);
        update_reg(ral.IE);

-       if (cfg != null) begin
-           cfg.u_cfg.data_width   = UART_DATA_8;
-           cfg.u_cfg.parity_sel   = UART_PAR_ODD;
-           cfg.u_cfg.stop_bit_sel = UART_STOP_1;
-           cfg.u_cfg.baudrate     = 9600;
-           cfg.u_cfg.clks_per_bit_cal();
-           uvm_config_db #(vsuart_cfg) :: set (null, "*", "cfg", cfg);
-           `uvm_info("updated_cfg", $sformatf("Update new configure to:\n%s", cfg.sprint), UVM_LOW)
-       end

        uart_enable();

    endtask

    // task: program only MODE.PDSEL/SPSEL
    virtual task config_datamode(uart_cfg u_cfg);
        if (ral == null) `uvm_fatal(get_type_name, "ral not connected")
        uart_disable();
        ral.MODE.PDSEL.set(pdsel_of(u_cfg));
        ral.MODE.SPSEL.set(u_cfg.stop_bit_sel == UART_STOP_2);
        update_reg(ral.MODE);
        `uvm_info(get_type_name, $sformatf("ral_datamode: PDSEL=%b SPSEL=%0d",
                  2'(ral.MODE.PDSEL.get()), ral.MODE.SPSEL.get()), UVM_HIGH)

        uart_enable();
        check_field(ral.MODE.UEN, 3'b111);
    endtask


    // function: BSEL/PRS/BRG giving the bit time closest to cpb 
    //   Fu_clk = Fsys_clk / (2 * (PRS + 1)),  BRG = Fu_clk / (OverSampling * baud) - 1
    //   => cpb = Fu_clk/BRG = 2 * (PRS + 1) * OverSampling * (BRG + 1),
    //  OS = 16 (BSEL=0) or 4 (BSEL=1)
    // For each BSEL/PRS, BRG + 1 = cpb / div rounded, limited to 2..65536 (BRG = 0
    // is not allowed). Returns the deviation |actual - cpb| in sys_clk cycles
    // (0: exact). Equal deviations keep the first one: OS = 16 first, then the
    // smallest PRS.
    protected function int unsigned find_divisors(int unsigned cpb, output bit bsel,
                                                  output bit [3:0] prs, output bit [15:0] brg);
        int unsigned os, div, n, actual, err;
        int unsigned best_err = '1;
        for (int b = 0; b < 2; b++) begin
            os = b ? 4 : 16;
            for (int p = 0; p < 16; p++) begin
                div = 2 * (p + 1) * os;
                n   = (cpb + div / 2) / div;  // BRG + 1, rounded
                if (n < 2)     n = 2;
                if (n > 65536) n = 65536;
                actual = div * n;
                err    = (actual > cpb) ? actual - cpb : cpb - actual;
                if (err < best_err) begin
                    best_err = err;
                    bsel = b;
                    prs  = p;
                    brg  = n - 1;
                    if (err == 0) return 0;
                end
            end
        end
        return best_err;
    endfunction

    // function: sys_clk cycles per bit programmed by BSEL/PRS/BRG
    protected function int unsigned bit_time(bit bsel, bit [3:0] prs, bit [15:0] brg);
        return 2 * (prs + 1) * (bsel ? 4 : 16) * (brg + 1);
    endfunction

    // function: PDSEL for the frame format
    //   11: 9-bit no parity, 10: 8-bit even, 01: 8-bit odd, 00: 8-bit no parity
    protected function bit [1:0] pdsel_of(uart_cfg cfg);
        if (cfg.data_width == UART_DATA_9) begin
            if (cfg.parity_sel != UART_PAR_NONE)
                `uvm_fatal(get_type_name, "9-bit data cannot have parity")
            return 2'b11;
        end
        case (cfg.parity_sel)
            UART_PAR_EVEN: return 2'b10;
            UART_PAR_ODD : return 2'b01;
            default      : return 2'b00;
        endcase
    endfunction
    
    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        init_rst(13, 10000);
        operate_rst(13, 10000);
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
