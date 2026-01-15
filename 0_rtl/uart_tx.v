//===========================================================================
//-- File Version    : 1.02
//-- Date            : 26/01/15
//-- Author          : kido
//-- IP Name         : uart_tx
//-- History         : ver.1.00 (26/01/03)
//--                 : ver.1.01 (26/01/13): fix fifo wr_en when disable
//--                 : ver.1.02 (26/01/15): fix tx_brk_done
//===========================================================================
module uart_tx #(
    parameter           P_FIFO_D        = 32,
    parameter           P_DATA_W        = 9
)(
    input                               clk,
    input                               rst_n,
    input   [P_DATA_W - 1   : 0]        i_data,
    input                               i_wr_en,
    input                               i_tx_en,
    input                               i_tx_pulse,
    input                               i_tx_brk,
    input                               i_mode_stop,    //-- 0: 1-stop-bit, 1: 2-stop-bits
    input   [1              : 0]        i_mode_pdata,   //-- 'b11: 9-bit data, no parity
                                                        //-- 'b10: 8-bit data, even parity
                                                        //-- 'b01: 8-bit data, odd parity
                                                        //-- 'b00: 8-bit data, no parity
    output                              o_fifo_full,    //-- 0: not full, 1: full
    output                              o_fifo_empty,   //-- 0: not empty, 1: empty
    output                              o_srt_st,       //-- 1: busy, 0: empty
    output                              o_tx_brk_done,      
    output                              o_tx            //-- serial data
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    localparam      P_IDLE_S    = 1'b1;     // output signal of tx in idle state
    localparam      P_START_S   = 1'b0;     // output signal of tx in start/stop bit
//---------------------------------------------------------------------------
    wire    [P_DATA_W - 1       : 0]    pdata;              // parallel data
    wire                                sdata;              // serial data
    wire                                parity;             // parity data
    wire    [1                  : 0]    sel;                // serial data
    wire                                fifo_rd_en;
    wire                                fifo_empty;
    wire                                fifo_full;
    wire                                srt_shift_right;    // Shift RegisTer shift right
    wire                                srt_st;             // Shift RegisTer status
    wire                                tx_brk_done;        
    reg                                 r_tx;               
// INSTANTIATE MODULE HERE---------------------------------------------------
    syn_fifo #(
        .P_DATA_W    (P_DATA_W),
        .P_DEPTH     (P_FIFO_D)
    ) u_syn_fifo (
        .clk         (clk),
        .rst_n       (rst_n),
        .i_data      (i_data),
        .i_wr_en     (i_wr_en & i_tx_en),
        .i_rd_en     (fifo_rd_en),
        .o_cnt       (),
        .o_full      (fifo_full),
        .o_empty     (fifo_empty),
        .o_data      (pdata)
    );
    uart_tx_p2s_shifter #(
        .P_DATA_W         (P_DATA_W)
    ) u_uart_tx_p2s_shifter (
        .clk              (clk),
        .i_data           (pdata),
        .i_load           (fifo_rd_en),
        // load parallel data in
        .i_shift_right    (srt_shift_right),
        // shift right control
        .o_data           (sdata)
    );
    uart_tx_parity_gen #(
        .P_DATA_W         (P_DATA_W)
    ) u_uart_tx_parity_gen (
        .clk              (clk),
        .i_data           (pdata),
        .i_en             (fifo_rd_en),
        // enable signal
        .i_mode_parity    (i_mode_pdata[0]),
        // 0: even parity, 1: odd parity
        .o_data           (parity)
    );
    uart_tx_controller u_uart_tx_controller (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_tx_en            (i_tx_en),
        .i_tx_pulse         (i_tx_pulse),
        .i_fifo_empty       (fifo_empty),
        .i_tx_brk           (i_tx_brk),
        .i_mode_stop        (i_mode_stop),
        .i_mode_pdata       (i_mode_pdata),
        //-- 'b11: 9-bit data, no parity
        //-- 'b10: 8-bit data, even parity
        //-- 'b01:  8-bit data, odd parity
        //-- 'b00:  8-bit data, no parity
        .o_fifo_rd_en       (fifo_rd_en),
        //-- fifo read enable
        .o_srt_st           (srt_st),
        //-- 1: busy, 0: empty
        .o_srt_shift_right  (srt_shift_right),
        .o_tx_brk_done      (tx_brk_done),
        .o_sel              (sel)
        //-- 0: idle/stop bit, 1: start, 2: serial data, 3: parity bit
    );
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if(!rst_n) begin
            r_tx <= 1'b1;
        end else if(i_tx_pulse) begin
            r_tx <= (sel == 2'd0)       ? P_IDLE_S  :
                    (sel == 2'd1)       ? P_START_S :
                    (sel == 2'd2)       ? sdata     : parity;
        end 
    end
//---------------------------------------------------------------------------
    assign o_tx             = r_tx;
    assign o_fifo_full      = fifo_full;
    assign o_fifo_empty     = fifo_empty;
    assign o_srt_st         = srt_st;
    assign o_tx_brk_done    = (i_tx_brk) ? tx_brk_done : 1'b0;
//---------------------------------------------------------------------------
endmodule
//===========================================================================