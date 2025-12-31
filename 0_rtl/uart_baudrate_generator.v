//===========================================================================
//-- File Version    : 1.00
//-- Date            : 25/12/31
//-- Author          : kido
//-- IP Name         : uart_baudrate_generator
//-- History         : ver.1.00 (25/12/31) 1st release
//--
//===========================================================================
module uart_baudrate_generator (
    input               clk,
    input               rst_n,
    input   [15 : 0]    i_brg_divisor,
    input               i_brg_hb_en,            // High Baud Rate Enable bit
    output              o_tx_pulse,
    output              o_rx_pulse
);
// LOCAL VARIABLE HERE-------------------------------------------------------
    // counter for create tx pulse
    reg     [15     : 0] tx_cnt;
    // selected tx divisor via high baud rate bit
    wire    [3      : 0] tx_divisor;
    // counter for create rx pulse
    reg     [3      : 0] rx_cnt;
    // next of tx_cnt
    wire    [15     : 0] tx_cnt_nxt;
    // next of rx_cnt
    wire    [15     : 0] rx_cnt_nxt;
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if(!rst_n) begin
            rx_cnt <= 16'd0;
        end else begin
            rx_cnt <= rx_cnt_nxt;
        end
    end
    assign rx_cnt_nxt = (rx_cnt == i_brg_divisor) ? 16'b0 : rx_cnt + 1'b1;
    assign o_rx_pulse = (rx_cnt == i_brg_divisor);
//---------------------------------------------------------------------------
    always @(posedge clk) begin
        if(!rst_n) begin
            tx_cnt <= 16'd0;
        end else begin
            tx_cnt <= tx_cnt_nxt;
        end
    end
    assign tx_divisor = (i_brg_hb_en) ? 4'd3 : 4'd15;
    assign tx_cnt_nxt = (o_rx_pulse == 1'b1) 
                            ? ((tx_cnt == tx_divisor)  ? 3'b0 : tx_cnt + 1'b1) 
                            : tx_cnt;
    assign o_tx_pulse = (tx_cnt == tx_divisor && o_rx_pulse);
//---------------------------------------------------------------------------
endmodule
//===========================================================================