//===========================================================================
//-- Author         : trizrd
//-- Name           : vsuart_rx_fifo_underflow_seq (UART configuration flow)
//-- History        : ver.1.00 (26/10/29) 1st release
//===========================================================================

class vsuart_rx_fifo_underflow_seq extends vsuart_base_seq;
  `uvm_object_utils(vsuart_rx_fifo_underflow_seq)

  int unsigned max_polls = 2000;

  function new(string name = "vsuart_rx_fifo_underflow_seq");
    super.new(name);
  endfunction

  task read_rbdsta(output bit rbdsta);
    uvm_status_e   status;
    uvm_reg_data_t value;
    ral.STA.read(status, value, .parent(this));
    if (status != UVM_IS_OK) `uvm_error(get_type_name, "STA read failed")
    rbdsta = ral.STA.RBDSTA.get_mirrored_value();
  endtask

  task wait_rbdsta_1(output bit ok);
    bit rbd;
    ok = 0;
    for (int unsigned i = 0; i < max_polls; i++) begin //timeout 20000us
      read_rbdsta(rbd);
      if (rbd) begin
        ok = 1;
        break;
      end
      #10us;
    end
  endtask

  task rd_rx_fifo(output bit [31:0] rdata, output bit slverr);
    apb_mst_rd_chk_seq rd = apb_mst_rd_chk_seq::type_id::create("rd");
    rd.start(a_seqr, this);
    rdata  = rd.rdata;
    slverr = rd.slverr;
  endtask

  virtual task body();
    bit rbd , slverr ,ok  ;
    bit [31:0] rdata;
    bit [8:0] exp_data;

    `uvm_info(get_type_name, "Body entered...", UVM_LOW)
    init_rst(13, 10000);  
    config_default(); 

    read_rbdsta(rbd);
    if (rbd != 0) `uvm_error(get_type_name, "RBDSTA != 0  after reset")

    rd_rx_fifo(rdata, slverr);
    if (slverr !== 1'b1) `uvm_error(get_type_name, "empty RX FIFO read: PSLVERR != 1")
    read_rbdsta(rbd);
    if (rbd !== 1'b0) `uvm_error(get_type_name, "RBDSTA changed after reading empty RX FIFO")
    
    uart_wdata();
    exp_data = uart_seq.seq_item.data;          
    if (cfg.u_cfg.data_width != UART_DATA_9) exp_data &= 9'h0FF; // mask bit 8 if data width is 8 bits
    
    wait_rbdsta_1(ok);
    if (!ok) `uvm_error(get_type_name, "RBDSTA never became 1 after one valid frame")

    rd_rx_fifo(rdata, slverr);
    if (slverr !== 1'b0) `uvm_error(get_type_name, "valid RX FIFO read: PSLVERR != 0")
    if (rdata[8:0] !== exp_data)
      `uvm_error(get_type_name, $sformatf("PRDATA=0x%0h, expected 0x%0h", rdata[8:0], exp_data))
 
    rd_rx_fifo(rdata, slverr);
    if (slverr !== 1'b1) `uvm_error(get_type_name, "second read: PSLVERR != 1")
 
    read_rbdsta(rbd);
    if (rbd !== 1'b0) `uvm_error(get_type_name, "RBDSTA != 0 at the end")
    `uvm_info(get_type_name, "Body end...", UVM_LOW)
  endtask
endclass