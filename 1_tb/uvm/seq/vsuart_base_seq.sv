//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_base_seq (virtual sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                : ver.1.01 (26/10/21) configure(), uart_enable(), uart_disable()
//--                :                     through the register model
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

    function new(string name = "vsuart_base_seq");
        super.new(name);
        r_seq = rst_base_seq::type_id::create("r_seq");
        uart_seq = uart_base_seq::type_id::create("uart_seq");
        apb_wdata_seq = apb_mst_wdata_seq::type_id::create("apb_wdata_seq");
        apb_rdata_seq = apb_mst_rdata_seq::type_id::create("apb_rdata_seq");
    endfunction

    // task: write data into dut rx
    virtual task uart_wdata();
        assert(uart_seq.randomize() with {});
        uart_seq.start(u_seqr);
    endtask

    // task: apb master read data
    virtual task apb_rd_data();
        assert(apb_rdata_seq.randomize());
        apb_rdata_seq.start(a_seqr);
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
        // run
        r_seq.start(r_seqr);
    endtask

    // task: initial reset
    virtual task init_rst(int interval_time = 8, int rst_time = 60);
        r_seq.req.interval_time = interval_time;
        r_seq.req.rst_time = rst_time;
        r_seq.req.rst_type = rst_item::CLK_PENDING;
        // run
        r_seq.start(r_seqr);
    endtask

    // task: write rg if its desired value differs from the mirror
    virtual task update_reg(uvm_reg rg);
        rg.update(status, .parent(this));
        if (status != UVM_IS_OK) `uvm_error(get_type_name, {rg.get_name(), " update failed"})
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
