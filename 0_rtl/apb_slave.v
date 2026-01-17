//--------------------------------------------------------------------
//-- Module: apb_slave
//-- Description:
//--  This module implements a simple APB (Advanced Peripheral Bus) slave device.
//-- 
//--------------------------------------------------------------------
module apb_slave #(
  parameter p_use_ack     = 0,          //0:no use ack/1:use ack
  parameter p_wr_wait     = 4'h0,       // write wait time
  parameter p_rd_wait     = 4'h0        // read wait time
)(
  //-- input signal
  //-- from APB_MASTER
  input              i_pclk,            // APB clock
  input              i_preset,          // APB reset 
  input       [31:0] i_paddr,           // APB address
  input       [ 2:0] i_pprot,           // APB protection(no use)
  input              i_psel,            // APB module select
  input              i_penable,         // APB module enable
  input              i_pwrite,          // APB write 1:write/0:read
  input       [31:0] i_pwdata,          // APB write data
  input       [ 3:0] i_pstrb,           // APB byte syrobe(no use)
  //-- from register
  input       [ 3:0] i_reg_rd_wait,     // register read wait
  input       [31:0] i_reg_rd_data,     // register read data
  input              i_reg_ack,         // register read/write ack
  input              i_reg_err,         // register error
  
  //-- output signal
  //-- for APB_MASTER
  output             o_pready,          // APB ready
  output      [31:0] o_prdata,          // APB read data
  output             o_pslverr,         // APB slave error
  //-- for register
  output      [31:0] o_reg_addr,        // register address
  output             o_reg_wr,          // register write enable
  output             o_reg_rd,          // register read enable
  output      [31:0] o_reg_wr_data,     // register write data
  output             o_reg_err_ack      // register error ack
);

  

  // ================= REGISTER =================
  reg          r_psel;
  reg  [3:0]   r_wait_cnt;
  reg          r_read_pos;
  reg          r_write_pos;
  reg          r_wait_ready;
  reg          r_ack_ready;
  reg          r_slv_err;
  reg  [31:0]  r_reg_addr;
  reg  [31:0]  r_reg_wr_data;
  reg  [31:0]  r_reg_rd_data;

  // ================= WIRE =================
  wire         w_psel;
  wire         w_penable;
  wire         w_psel_pos;
  wire         w_pwrite;
  wire         w_pread;
  wire         w_pwrite_pos;
  wire         w_pread_pos;
  wire         w_wait_wr_ready;
  wire         w_wait_rd_ready;
  wire         w_wr_cnt_chk;
  wire         w_rd_cnt_chk;
  wire         w_wait_ready;
  wire         w_ready;
  wire         w_nowait_rd_ready;
  wire         w_nowait_wr_ready;
  wire         w_psel_pos_wr;
  wire         w_psel_pos_rd;
  wire         w_pdone;
  wire  [3:0]  w_rd_wait;
  wire         w_sel_ack;
  wire         w_sel_pready;

  // ================= OUTPUT =================
  assign o_reg_rd      = r_read_pos;
  assign o_reg_wr      = r_write_pos;
  assign o_pready      = w_sel_pready;
  assign o_pslverr     = r_slv_err;
  assign o_reg_addr    = r_reg_addr;
  assign o_reg_wr_data = r_reg_wr_data;
  // assign o_prdata      = r_reg_rd_data;
  assign o_prdata      = i_reg_rd_data;
  assign o_reg_err_ack = w_pdone;

  // ================= INPUT DECODE =================
  assign w_psel    =  i_psel & ~i_penable;
  assign w_penable =  i_psel &  i_penable;
  assign w_pwrite  =  i_pwrite & i_penable;
  assign w_pread   = ~i_pwrite & i_penable;
  assign w_pdone   =  i_penable & o_pready;

  // ================= PSEL EDGE =================
  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_psel <= 1'b0;
    else
      r_psel <= w_psel;
  end

  assign w_psel_pos   = w_psel & ~r_psel;
  assign w_pread_pos  = w_psel_pos & ~i_pwrite;
  assign w_pwrite_pos = w_psel_pos &  i_pwrite;

  // ================= READ / WRITE FLAG =================
  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_read_pos <= 1'b0;
    else if (w_pdone)
      r_read_pos <= 1'b0;
    else if (w_pread_pos)
      r_read_pos <= 1'b1;
  end

  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_write_pos <= 1'b0;
    else
      r_write_pos <= w_pwrite_pos;
  end

  // ================= WAIT COUNTER =================
  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_wait_cnt <= 4'h0;
    else if (w_psel_pos | w_pdone)
      r_wait_cnt <= 4'h0;
    else if (w_penable)
      r_wait_cnt <= r_wait_cnt + 4'h1;
  end

  assign w_rd_wait       = (i_reg_rd_wait == 4'hF) ? 4'hF : i_reg_rd_wait + 4'h1;
  assign w_wr_cnt_chk    = (r_wait_cnt == (p_wr_wait - 4'h1));
  assign w_rd_cnt_chk    = (r_wait_cnt >= (w_rd_wait - 4'h1));

  assign w_wait_wr_ready = w_wr_cnt_chk & w_pwrite;
  assign w_wait_rd_ready = w_rd_cnt_chk & w_pread;
  assign w_wait_ready    = w_wait_wr_ready | w_wait_rd_ready;

  assign w_nowait_wr_ready = (p_wr_wait == 4'h0) ? r_write_pos : 1'b0;
  assign w_nowait_rd_ready = (p_rd_wait == 4'h0) ? r_read_pos  : 1'b0;

  assign w_psel_pos_wr = w_pwrite_pos & (p_wr_wait != 4'h0);
  assign w_psel_pos_rd = w_pread_pos  & (w_rd_wait != 4'h0);

  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_wait_ready <= 1'b1;
    else if (w_psel_pos_wr | w_psel_pos_rd)
      r_wait_ready <= 1'b0;
    else if (w_wait_ready)
      r_wait_ready <= 1'b1;
  end

  assign w_ready = w_nowait_rd_ready | w_nowait_wr_ready | r_wait_ready;

  // ================= ACK READY =================
  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_ack_ready <= 1'b1;
    else if (w_pdone)
      r_ack_ready <= 1'b1;
    else if (w_psel_pos)
      r_ack_ready <= 1'b0;
    else if (i_reg_ack)
      r_ack_ready <= 1'b1;
  end

  assign w_sel_pready = (p_use_ack) ? r_ack_ready : w_ready;

  // ================= REGISTER ADDR / DATA =================
  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_reg_addr <= 32'h0;
    else if (w_psel_pos)
      r_reg_addr <= i_paddr;
  end

  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_reg_wr_data <= 32'h0;
    else if (w_pwrite_pos)
      r_reg_wr_data <= i_pwdata;
  end

  assign w_sel_ack = (p_use_ack) ? i_reg_ack : w_wait_rd_ready;


  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_reg_rd_data <= 32'h0;
    else if (w_sel_ack)
      r_reg_rd_data <= i_reg_rd_data;
    else
      r_reg_rd_data <= i_reg_rd_data;
  end


  // ================= ERROR =================
  always @(posedge i_pclk or negedge i_preset) begin
    if (!i_preset)
      r_slv_err <= 1'b0;
    else if (w_pdone)
      r_slv_err <= 1'b0;
    else if (i_reg_err)
      r_slv_err <= 1'b1;
  end

endmodule
