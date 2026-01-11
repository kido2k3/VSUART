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
    
    // Transaction Class
    class item;
        //input
        bit [P_DATA_W - 1 : 0]   i_data;
        bit                      i_wr_en;
        bit                      i_tx_en;
        bit                      i_tx_pulse;
        bit                      i_tx_brk;
        bit                      i_mode_stop;
        bit [1:0]                i_mode_pdata;
        
        //output
        logic                         o_fifo_full;
        logic                         o_fifo_empty;
        logic                         o_srt_st;
        logic                         o_tx;
        logic                         o_tx_brk_done;
        
        function void display(string prefix = "");
            $display("[%0t]%s Data=0x%0h TxBrk=%0b Stop=%0b Pdata=%0b", 
                     $time, prefix, i_data, i_tx_brk, i_mode_stop, i_mode_pdata);
        endfunction
    endclass
    
    typedef struct {
        bit [P_DATA_W-1:0] data;
        bit [1:0]          mode_pdata;  
        bit                mode_stop;   
        bit                tx_brk;     
        bit                tx_en; 
        bit                wr_en;
        string             description;
        bit                expected_pass;
    } uart_test;
    
    uart_test testcases[] = '{
        '{8'b1100_0011, 2'b10, 0, 0, 0, 1, "Not enable", 0},
        '{8'b1000_0010, 2'b10, 0, 0, 1, 0, "Not enable write fifo, data sequence", 0},
        '{8'b1000_0110, 2'b10, 0, 1, 1, 0, "Not enable write fifo, break sequence", 1},
        '{8'b1100_0011, 2'b10, 0, 0, 1, 1, "8-bit data, even parity, 1 stop bit", 1},
        '{9'b1_1100_0001, 2'b11, 0, 1, 1, 1, "break", 1},
        '{9'd257,         2'b11, 0, 0, 1, 1, "9-bit data, no parity, 1 stop bits", 1},
        '{8'b1010_1010, 2'b01, 0, 0, 1, 1, "8-bit data, odd parity, 1 stop bit", 1},
        '{8'b1111_1111, 2'b00, 0, 0, 1, 1, "8-bit data, no parity, 1 stop bits", 1},
        '{8'b1111_1111, 2'b00, 1, 0, 1, 1, "8-bit data, no parity, 2 stop bits", 1},
        '{8'b0000_0000, 2'b10, 1, 0, 1, 1, "8-bit data, even parity, 2 stop bits", 1},
        '{8'b0101_0101, 2'b01, 1, 0, 1, 1, "8-bit data, odd parity, 2 stop bits", 1},
        '{9'b1_1111_0101, 2'b11, 1, 0, 1, 1, "9-bit data, no parity, 2 stop bits", 1},
        '{9'b1_1100_0001, 2'b10, 0, 1, 1, 1,"break", 1}
    };
    
    // DUT Interface Signals
    reg   [P_DATA_W - 1 : 0]    i_data;
    reg                         i_wr_en;
    reg                         i_tx_en;
    reg                         i_tx_pulse;
    reg                         i_tx_brk;
    reg                         i_mode_stop;
    reg   [1:0]                 i_mode_pdata;
    
    wire                        o_fifo_full;
    wire                        o_fifo_empty;
    wire                        o_srt_st;
    wire                        o_tx;
    wire                        o_tx_brk_done;
    
    // Monitor Variables
    item my_item;
    int  transaction_count;
    int  error_count;
    
//---------------------------------------------------------------------------
    // CLK_GEN
    initial begin
        clk = 0;
        forever #(clk_cycle / 2) clk = ~clk;
    end
    
//---------------------------------------------------------------------------
    // RST_GEN
    initial begin
        wait_for_rst = 0;
        rst_n = 0;
        @(posedge clk); 
        #0.1;
        rst_n = 1;
        wait_for_rst = 1;
    end
    
//---------------------------------------------------------------------------
    // DUT Instantiation
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
        .o_fifo_full      (o_fifo_full),
        .o_fifo_empty     (o_fifo_empty),
        .o_srt_st         (o_srt_st),
        .o_tx             (o_tx),
        .o_tx_brk_done    (o_tx_brk_done)
    );
    
//---------------------------------------------------------------------------
    // TX Pulse Generator
    initial begin: tx_pulse_driver
        i_tx_pulse = 0;
        wait(wait_for_rst);
        forever begin
            repeat(15) @(posedge clk);
            i_tx_pulse = 1;
            @(posedge clk);
            i_tx_pulse = 0;
        end 
    end
    
//---------------------------------------------------------------------------
    initial begin
        foreach (end_block_flag[i]) begin
            end_block_flag[i] = 0;
        end
        transaction_count = 0;
        error_count = 0;
    end
    
//---------------------------------------------------------------------------
    initial begin : driver
        $display ("//=====================================//");
        $display ("//-- [%8t] Simulation Start !!! --//", $time);
        $display ("//=====================================//");
        
        // Initialize
        my_item = new();
        initialize_signals();
        wait(wait_for_rst);
        
        @(posedge clk);
        
        for (int i = 0; i < testcases.size(); i++) begin
            $display("\n//-- Test Case %0d: %s --//", i, testcases[i].description);
            run_testcase(testcases[i]);
        end
        
        wait(o_fifo_empty && !o_srt_st);
        repeat(100) @(posedge clk);
        
        end_block_flag[0] = 1;
    end
    
//---------------------------------------------------------------------------
    // Monitor Process
    initial begin : monitor

        
        wait(wait_for_rst);

        
        fork
            begin

            end
            begin
                wait(end_block_flag[0]);
                end_block_flag[1] = 1;
            end
        join_any
    end
    
//---------------------------------------------------------------------------
    // Scoreboard
    initial begin: scoreboard
        wait(end_block_flag[0] & end_block_flag[1]);
        
        $display ("\n//===================================//");
        $display ("//-- Simulation Summary            --//");
        $display ("//===================================//");
        $display ("Total Transactions: %0d", transaction_count);
        $display ("Errors Detected   : %0d", error_count);
        
        if (error_count == 0)
            $display ("//-- STATUS: PASSED               --//");
        else
            $display ("//-- STATUS: FAILED               --//");
            
        $display ("//===================================//");
        $display ("//-- [%8t] Simulation End !!! --//", $time);
        $display ("//===================================//");
        $finish;
    end
    
//---------------------------------------------------------------------------
    // Waveform Dump
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_uart_tx);
    end
    
//---------------------------------------------------------------------------
    // Tasks
    
    task initialize_signals();
        i_data       = 0;
        i_wr_en      = 0;
        i_tx_en      = 0;
        i_tx_brk     = 0;
        i_mode_stop  = 0;
        i_mode_pdata = 0;
    endtask
    
    task run_testcase(uart_test tc);
        assign_item(tc);
        drive_item(my_item);
        
        if (tc.expected_pass)
            wait(o_tx_brk_done);
        else begin
            repeat(15) @(posedge i_tx_pulse);
        end


        
        transaction_count++;
        repeat(10) @(posedge clk);
    endtask
    
    task drive_item(item it);
        @(posedge clk);
        i_data       = it.i_data;
        i_mode_pdata = it.i_mode_pdata;
        i_mode_stop  = it.i_mode_stop;
        i_tx_brk     = it.i_tx_brk;
        i_wr_en      = it.i_wr_en;
        i_tx_en      = it.i_tx_en;
        
        @(posedge clk);
        i_wr_en      = 0;
        it.display("[DRV] ");
            
    endtask
    
    task assign_item(uart_test tc);
        my_item.i_data       = tc.data;
        my_item.i_mode_pdata = tc.mode_pdata;
        my_item.i_mode_stop  = tc.mode_stop;
        my_item.i_tx_brk     = tc.tx_brk;
        my_item.i_wr_en      = tc.wr_en;
        my_item.i_tx_en      = tc.tx_en;
    endtask
    
    // task apply_reset();
    //     @(posedge clk);
    //     rst_n = 0;
    //     initialize_signals();
    //     @(posedge clk); 
    //     #0.1;
    //     rst_n = 1;
    //     @(posedge clk);
    // endtask
    
//---------------------------------------------------------------------------
endmodule
//===========================================================================