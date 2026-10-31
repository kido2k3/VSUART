//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_rx_basic_seq (UART configuration flow)
//-- History        : ver.1.00 (26/10/29) 1st release
//===========================================================================

class vsuart_rx_basic_seq extends vsuart_base_seq;
  `uvm_object_utils(vsuart_rx_basic_seq)
 
  int frame_num =10;
  int rx_cnt;                 //rx_cnt == frame_num
 
  function new(string name = "vsuart_rx_basic_seq");
    super.new(name);
  endfunction
 
  task sent_frame();
    if (!cfg.u_cfg.randomize() with {
      baudrate == baud;
    })
      `uvm_fatal(get_type_name, "uart_cfg randomize failed")
    else begin
      `uvm_info("updated_cfg_trizrd", $sformatf("Update new configure to:\n%s", cfg.sprint), UVM_LOW)
      uvm_config_db #(vsuart_cfg)::set(null, "*", "cfg", cfg);
    end
    config_default();
    uart_wdata();
    // read RX fifo
  endtask
 
  virtual task body();
    `uvm_info(get_type_name, "Body entered...", UVM_LOW)
    // init reset
    init_rst(13, 10000);
    config_default();
 
    sent_frame(); // sent one valid frame
    wait_rx_fifo_not_empty();
    apb_rd_data();
    rx_cnt = 0;
    repeat (frame_num) begin
      sent_frame(); // send 128 frame
      apb_rd_data();
      rx_cnt ++;
      `uvm_info("trizrd frame", $sformatf("frame num = %0d", rx_cnt), UVM_LOW)
    end

    wait_rx_fifo_not_empty();

    if (rx_cnt != frame_num)
      `uvm_error(get_type_name, $sformatf("Lost frame: %0d/%0d", rx_cnt, frame_num))
 
    `uvm_info(get_type_name, "Body end...", UVM_LOW)
  endtask
endclass
