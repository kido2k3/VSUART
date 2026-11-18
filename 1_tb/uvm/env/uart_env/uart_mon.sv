//======================================================================
// Author   : Trizrd
// Name     : uart_mon (uart monitor)
// History  : ver.1.00 (26/10/17) 1st release
//          : ver.1.01 simple version: bit time measured from the line
//          : (start edge -> 1st rising edge), sample once at bit center,
//======================================================================
class uart_mon extends uvm_monitor;
  `uvm_component_utils(uart_mon)

  typedef enum bit {BAD_WIDTH = 1'b0, BREAK = 1'b1} width_err_e;

  virtual uart_if vif;
  uart_cfg cfg;
  real t_clk;
  real baud_tol_pct = 2.0; // allowed |bit_time - nominal| / nominal (%)
  real meas_cpb [2];       // last measured clocks per bit, index = dir (0 rx, 1 tx)

  uvm_analysis_port #(uart_item) as_tx_port;
  uvm_analysis_port #(uart_item) as_rx_port;

  function new (string name, uvm_component parent);
    super.new (name, parent);
  endfunction

  // build phase: get vif
  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    `uvm_info("build_phase", "Entered...", UVM_LOW)
    as_tx_port = new ("as_tx_port", this);
    as_rx_port = new ("as_rx_port", this);

    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", vif))
      `uvm_fatal("NOT_IF", "interface not found")

    if (!uvm_config_db #(uart_cfg)::get(this, "", "uart_cfg", cfg))
      `uvm_fatal("NOT_CFG", "UART configured not found")

    // optional knob override
    void'(uvm_config_db #(real)::get(this, "", "baud_tol_pct", baud_tol_pct));
    `uvm_info("build_phase", "Exit...", UVM_LOW)
  endfunction

  virtual task run_phase (uvm_phase phase);
    clk_measure(); // measure clock period once
    forever begin
      wait (vif.rst_n === 1'b1); // wait till reset deassert
      fork begin : mon_threads
        fork
          tx_flow();
          rx_flow();
          wait (vif.rst_n !== 1'b1); // reset assert (or X) -> exit
        join_any
        disable fork; // kill tx_flow and rx_flow to clear state
      end join
    end
  endtask

  function logic get_tx_rx (bit dir);
    return dir ? vif.mon_if.u_tx : vif.mon_if.u_rx; // 1 -> tx, 0 -> rx
  endfunction

  task tx_flow;
    uart_item tx_item;
    bit       valid;
    `uvm_info("MON_START", $sformatf("tx_flow started at %0t", $time), UVM_LOW)
    wait_idle(1'b1); // once: first frame after reset starts from idle
    forever begin
      tx_item = uart_item::type_id::create("tx_item");
      collect_frame(1'b1, tx_item, valid);
      if (valid) begin
        `uvm_info("MON_TX", tx_item.sprint(), UVM_LOW)
        as_tx_port.write(tx_item);
        // resync: after break / bad stop the line may still be low
        if (tx_item.frame_error) wait_idle(1'b1);
      end
    end
  endtask

  task rx_flow;
    uart_item rx_item;
    bit       valid;
    `uvm_info("MON_START", $sformatf("rx_flow started at %0t", $time), UVM_LOW)
    wait_idle(1'b0);
    forever begin
      rx_item = uart_item::type_id::create("rx_item");
      collect_frame(1'b0, rx_item, valid);
      if (valid) begin
        `uvm_info("MON_RX", rx_item.sprint(), UVM_LOW)
        as_rx_port.write(rx_item);
        if (rx_item.frame_error) wait_idle(1'b0);
      end
    end
  endtask

  // measure clock period of mon_if
  task clk_measure();
    real t0, t1;
    @(vif.mon_if);
    t0 = $realtime;
    repeat (8) @(vif.mon_if);
    t1 = $realtime;
    t_clk = (t1 - t0) / 8.0;
    if (t_clk <= 0.0)
      `uvm_fatal("MON_CLK", $sformatf("invalid t_clk=%0f", t_clk))
    `uvm_info("MON_CLK", $sformatf("t_clk=%0f", t_clk), UVM_LOW)
  endtask

  // wait until line is high (IDLE)
  task wait_idle(bit dir);
    while (get_tx_rx(dir) !== 1'b1) @(vif.mon_if);
  endtask

  task wait_start(bit dir);
    while (get_tx_rx(dir) !== 1'b0) @(vif.mon_if); // START
  endtask

  task wait_until (real t);
    real dly;
    dly = t - $realtime;
    if (dly > 0.0) #(dly);
  endtask

  function real rabs (real x);
    return (x < 0.0) ? -x : x;
  endfunction

  // report break or bad width and fill the item
  task width_gone_wrong (width_err_e err_type, real t_timeout, real t_width,
                         int n_bits_low, int max_n,
                         uart_item item, output bit valid);
    if (err_type == BREAK)
      `uvm_error("MON_BREAK", $sformatf("line low longer than max legal time %0f", t_timeout))
    else
      `uvm_error("MON_BITTIME", $sformatf("low width=%0f -> N=%0d > max %0d: stop bit low",
                                          t_width, n_bits_low, max_n))
    item.data         = '0;
    item.parity_error = 0;
    item.frame_error  = 1;
    item.end_time     = $rtoi($realtime);
    valid             = 1;
  endtask

  task collect_frame (bit dir, uart_item item, output bit valid);
    int n_data, n_stop, n_par, max_n, total_bits, n_bits_low;
    bit [8:0] d;
    bit par_bit, exp_par, has_par, has_xz, got_rise;
    logic vals [16];
    logic smp;
    real t_nominal, bit_time, t_start, t_rise, t_width, t_timeout;
    real t_sample, dev_pct;

    valid  = 0;
    d      = '0;
    has_xz = 0;

    wait_start(dir);
    t_start         = $realtime;
    item.start_time = $rtoi(t_start);

    // cfg is read AFTER the start edge, so it is the cfg of THIS frame
    if (!uvm_config_db #(uart_cfg)::get(this, "", "uart_cfg", cfg))
      `uvm_fatal("NOT_CFG", "UART configured not found")

    if (cfg.clks_per_bit < 2)
      `uvm_fatal("MON_CFG", $sformatf("clks_per_bit=%0d, cfg not yet calculated (if_clk_freq=%0d baud=%0d)",
                                      cfg.clks_per_bit, cfg.if_clk_freq, cfg.baudrate))

    n_data  = (cfg.data_width   == UART_DATA_9) ? 9 : 8;
    n_stop  = (cfg.stop_bit_sel == UART_STOP_2) ? 2 : 1;
    has_par = (cfg.parity_sel   != UART_PAR_NONE);
    n_par   = has_par ? 1 : 0;

    t_nominal  = cfg.clks_per_bit * t_clk;
    max_n      = n_data + n_par + 1; // start + data (+ parity) all zero; longer low -> error
    total_bits = 1 + n_data + n_par + n_stop;

    t_timeout = (max_n + 0.5) * t_nominal * (1.0 + baud_tol_pct/100.0);
    got_rise  = 0;

    fork begin
      fork
        begin wait_idle(dir); got_rise = 1; end
        begin #(t_timeout); end
      join_any
      disable fork;
    end join

    if (!got_rise) begin
      width_gone_wrong(BREAK, t_timeout, 0.0, 0, max_n, item, valid);
      return; // line still low -> caller does wait_idle (frame_error=1)
    end

    t_rise     = $realtime;
    t_width    = t_rise - t_start;
    n_bits_low = $rtoi(t_width / t_nominal + 0.5);

    if (n_bits_low < 1) begin
      `uvm_error("MON_GLITCH", $sformatf("t_width %0f shorter than half bit (nominal=%0f)", t_width, t_nominal))
      return; // line is high now, valid stays 0
    end

    if (n_bits_low > max_n) begin
      width_gone_wrong(BAD_WIDTH, t_timeout, t_width, n_bits_low, max_n, item, valid);
      return; // line is high now
    end

    bit_time = t_width / n_bits_low; // real bit time of DUT
    for (int j = 0; j < n_bits_low; j++) vals[j] = 1'b0; // low run: start + leading zeros

    for (int j = n_bits_low; j < total_bits; j++) begin
      t_sample = t_rise + (j + 0.5 - n_bits_low) * bit_time; // center of bit j
      wait_until(t_sample);
      smp     = get_tx_rx(dir);
      vals[j] = smp;
      if ($isunknown(smp)) has_xz = 1;
    end

    meas_cpb[dir] = bit_time / t_clk;
    dev_pct       = ((bit_time - t_nominal) / t_nominal) * 100.0;
    if (rabs(dev_pct) > baud_tol_pct)
      `uvm_error("MON_BAUD", $sformatf("bit time deviates %0.2f%% from cfg (tol=%0.2f%%)", dev_pct, baud_tol_pct))

    for (int i = 0; i < n_data; i++) d[i] = vals[1 + i]; // LSB first

    item.parity_error = 0;
    if (has_par) begin
      par_bit = vals[1 + n_data];
      exp_par = (cfg.parity_sel == UART_PAR_EVEN) ? (^d) : (~^d);
      if (par_bit !== exp_par) item.parity_error = 1;
    end

    item.frame_error = 0;
    for (int s = 0; s < n_stop; s++) begin
      if (vals[1 + n_data + n_par + s] !== 1'b1) item.frame_error = 1;
    end

    if (has_xz) begin
      `uvm_error("MON_XZ", "X/Z sampled on the line inside a frame")
      item.frame_error = 1;
    end

    item.data     = d;
    item.end_time = $rtoi(t_start + total_bits * bit_time); // end of last stop bit
    valid         = 1;
  endtask

endclass