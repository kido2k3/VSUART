//===========================================================================
//-- File Version    : 1.00
//-- Date            : 26/1/1
//-- Author          : kido
//-- IP Name         : tb_uart_tx
//-- History         : ver.1.00 (26/1/1) 1st release
//--
//===========================================================================
module tb_uart_tx;
//---------------------------------------------------------------------------
    // VARIABLE OF CLOCK
    parameter          clk_cycle    = 4;
    reg                clk;
    reg                rst_n;
    reg                end_block_flag [4];
    reg                wait_for_rst;
//---------------------------------------------------------------------------
    // INSERT VARIABLE HERE
    parameter           P_FIFO_D        = 32;
    parameter           P_DATA_W        = 9;
    class item;
        bit   [P_DATA_W - 1   : 0]        i_data;
        bit                               i_wr_en;
        bit                               i_tx_en;
        bit                               i_tx_pulse;
        bit                               i_tx_brk;
        bit                               i_mode_stop;
        bit   [1              : 0]        i_mode_pdata;   //-- 'b11: 9-bit data; no parity
                                                    //-- 'b10: 8-bit data; even parity
                                                    //-- 'b01: 8-bit data; odd parity
                                                    //-- 'b00: 8-bit data; no parity
        logic                              o_fifo_full;    //-- 0: not full; 1: full
        logic                              o_fifo_empty;   //-- 0: not empty; 1: empty
        logic                              o_srt_st;       //-- 1: busy; 0: empty
        logic                              o_tx;            //-- serial data
    endclass
        reg   [P_DATA_W - 1   : 0]        i_data = 0;
        reg                               i_wr_en = 0;
        reg                               i_tx_en = 0;
        reg                               i_tx_pulse = 0;
        reg                               i_tx_brk = 0;
        bit                               i_mode_stop = 0;
        reg   [1              : 0]        i_mode_pdata = 0;   //-- 'b11: 9-bit data; no parity
                                                    //-- 'b10: 8-bit data; even parity
                                                    //-- 'b01: 8-bit data; odd parity
                                                    //-- 'b00: 8-bit data; no parity
        wire                              o_fifo_full;    //-- 0: not full; 1: full
        wire                              o_fifo_empty;   //-- 0: not empty; 1: empty
        wire                              o_srt_st;       //-- 1: busy; 0: empty
        wire                              o_tx;            //-- serial data
//---------------------------------------------------------------------------
    // CLK_GEN
    initial begin
        clk <= 0;
        forever #(clk_cycle / 2) clk <= ~clk;
    end
//---------------------------------------------------------------------------
    // RST_GEN
    initial begin
        rst_n <= 0;
        @(posedge clk); 
        #0.1;
        rst_n <= 1;
        wait_for_rst <= 1;
    end
//---------------------------------------------------------------------------
    // instantiate module here
    uart_tx #(
        .P_FIFO_D         (P_FIFO_D),
        .P_DATA_W         (P_DATA_W)
    ) u_uart_tx (
        .clk              (clk),
        .rst_n            (rst_n),
        .i_data           (i_data),
        .i_wr_en          (i_wr_en),
        .i_tx_en          (i_tx_en),
        .i_tx_pulse       (i_tx_pulse),
        .i_tx_brk         (i_tx_brk),
        .i_mode_stop      (i_mode_stop),
        .i_mode_pdata     (i_mode_pdata),
        //-- 'b11: 9-bit data, no parity
        //-- 'b10: 8-bit data, even parity
        //-- 'b01: 8-bit data, odd parity
        //-- 'b00: 8-bit data, no parity
        .o_fifo_full      (o_fifo_full),
        //-- 0: not full, 1: full
        .o_fifo_empty     (o_fifo_empty),
        //-- 0: not empty, 1: empty
        .o_srt_st         (o_srt_st),
        //-- 1: busy, 0: empty
        .o_tx             (o_tx)
        //-- serial data
    );
//---------------------------------------------------------------------------
    initial begin
        foreach (end_block_flag[i]) begin
            end_block_flag[i] <= 0;
        end
    end
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
    initial begin: tx_pulse_driver
        forever begin
            i_tx_pulse <= 0;
            repeat(15) @(posedge clk);
            i_tx_pulse <= 1;
            @(posedge clk);
        end 
    end
    initial begin : driver
        $display ("//=====================================//");
        $display ("//-- [%8t] Simulation Start !!! --//", $time);
        $display ("//=====================================//");
// INITIAL DATA HERE---------------------------------------------------------
        wait_for_rst <= 0;
        wait(wait_for_rst);
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
        // CODE HERE
        fork
            begin: wr_en_data
                @(posedge clk);
                i_wr_en <= 1;
                i_data <= 9'b0_1100_0011;
                i_mode_pdata <= 2'b10;
                i_mode_stop <= 0;
                @(posedge clk);
                i_wr_en <= 0;
                repeat(210) @(posedge clk);
                i_wr_en <= 1;
                i_data <= 9'b1_1100_0001;
                i_mode_pdata <= 2'b11;
                i_mode_stop <= 0;
                @(posedge clk);
                i_wr_en <= 0;
                repeat(210) @(posedge clk);
                i_wr_en <= 1;
                i_data <= 9'd257;
                i_mode_pdata <= 2'b11;
                i_mode_stop <= 1;
                @(posedge clk);
                i_wr_en <= 0;
            end
            begin
                i_tx_en <= 1;
                i_tx_brk <= 0;
            end
        join
//---------------------------------------------------------------------------
        repeat(1000) @(posedge clk);
//---------------------------------------------------------------------------
        repeat(5) @(posedge clk);
        end_block_flag[0] <= 1;
    end
//---------------------------------------------------------------------------
    // OTHER CODE 
//---------------------------------------------------------------------------
    initial begin : monitor
        forever begin
            @(posedge clk);
        end
    end
//---------------------------------------------------------------------------
    initial begin: scoreboard
        wait(end_block_flag[0]);
        $display ("//===================================//");
        $display ("//-- [%8t] Simulation End !!! --//", $time);
        $display ("//===================================//");
        $finish;
    end
//---------------------------------------------------------------------------
    initial begin
        // $dumpfile();     // $dumpfile(<filename>);
        // $dumpvars (0);        // Dumps all variables from all module instances
        // $dumpvars (0, tb_switch_modeling);    // Dumps all variables within module 'tb' and in all sub-modules
        // $dumpvars (1, tb);    // Dumps all variables within module 'tb', not in any sub-modules
        // $dumpvars (0, tb.ram_ctrl, tb.alu2.a);  // Dumps all variables in 'tb.ram_ctrl' and in all its sub-modules, and the variable 'tb.alu2.a' in module 'alu2'
    end
//---------------------------------------------------------------------------
endmodule
//===========================================================================