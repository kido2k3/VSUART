//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_full_duplex_seq (UART configuration flow)
//-- History        : ver.1.00 (26/10/29) 1st release
//===========================================================================

class vsuart_full_duplex_seq extends vsuart_base_seq;
  `uvm_object_utils(vsuart_full_duplex_seq)

  int unsigned num = 10;
  bit [8:0]    tx_payload[];

  function new(string name = "vsuart_full_duplex_seq");
    super.new(name);
  endfunction

  task tx_write_thread();
    apb_mst_wdata_burst_seq burst = apb_mst_wdata_burst_seq::type_id::create("burst");
    burst.payload = new[num];
    foreach (burst.payload[i])
      burst.payload[i] = 9'($urandom_range(8'hFF, 0));   // bit 8 = 0
    tx_payload = burst.payload;
    burst.start(a_seqr, this);
  endtask

  task rx_send_thread();
    repeat (num) uart_wdata();   // bo repeat neu uart_base_seq da gui nhieu frame
  endtask

  task rx_read_thread();
    repeat (num) begin
      wait_rx_fifo_not_empty();
      apb_rd_data();
    end
  endtask

  task wait_tx_done();
    uvm_status_e   st;
    uvm_reg_data_t v;
    do ral.STA.read(st, v, .parent(this));
    while (!(ral.STA.TRSTA.get_mirrored_value() == 1 &&
             ral.STA.TBSTA.get_mirrored_value() == 0));
  endtask

  task check_final_status();
    uvm_status_e   st;
    uvm_reg_data_t v;
    ral.STA.read(st, v, .parent(this));
    if (ral.STA.TBSTA.get_mirrored_value()  != 0) `uvm_error(get_type_name, "TBSTA != 0")
    if (ral.STA.TISTA.get_mirrored_value()  != 1) `uvm_error(get_type_name, "TISTA != 1")
    if (ral.STA.TRSTA.get_mirrored_value()  != 1) `uvm_error(get_type_name, "TRSTA != 1")
    if (ral.STA.RISTA.get_mirrored_value()  != 1) `uvm_error(get_type_name, "RISTA != 1")
    if (ral.STA.RBDSTA.get_mirrored_value() != 0) `uvm_error(get_type_name, "RBDSTA != 0")
    if (ral.STA.RBOSTA.get_mirrored_value() != 0) `uvm_error(get_type_name, "RBOSTA != 0")
  endtask

  virtual task body();
    `uvm_info(get_type_name, "Body entered...", UVM_LOW)

    init_rst(13, 10000);  
    config_default();      

    fork                   
      tx_write_thread();
      rx_send_thread();
      rx_read_thread();
    join

    wait_tx_done();
    check_final_status();

    `uvm_info(get_type_name, "Body end...", UVM_LOW)
  endtask
endclass