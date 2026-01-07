//===========================================================================
//-- File Version    : 1.01
//-- Date            : 26/01/06
//-- Author          : manh
//-- IP Name         : tb_uart_baudrate_generator
//-- History         : ver.1.00 (25/12/28) 1st release
//--                 : ver.1.01 (26/01/06) add new test cases
//===========================================================================
module tb_uart_baudrate_generator;
//---------------------------------------------------------------------------
    // VARIABLE OF CLOCK
    parameter          clk_cycle    = 4;
    reg                clk;
    reg                rst_n;
    reg                end_block_flag [4];
    reg                wait_for_rst;
//----------------BASE ITEM--------------------------------------------------
    class item;
        bit    [15 : 0]    i_brg_divisor;
        bit                i_brg_hb_en;            // High Baud Rate Enable bit
        logic              o_tx_pulse;
        logic              o_rx_pulse;
    endclass
    logic    [15 : 0]    i_brg_divisor;
    logic                i_brg_hb_en;            // High Baud Rate Enable reg
    logic              o_tx_pulse;
    logic              o_rx_pulse;


//----------------Test Case Class--------------------------------------------
    typedef struct {
        int divisor;
        bit hb;
    } brg_test;

    brg_test testcases[] = '{
        '{100,    0},
        '{50,     1},
        '{1,      0},
        '{1,      1},
        '{65535,  0},
        '{65535,  1}
    };    
//----------------VARIABLE---------------------------------------------------
    item my_item = new();
//---------------------------------------------------------------------------
    // CLK_GEN
    initial begin
        clk = 0;
        forever #(clk_cycle / 2) clk = ~clk;
    end
//---------------------------------------------------------------------------
    // RST_GEN
    initial begin
        rst_n = 0;
        @(posedge clk); 
        #0.1;
        rst_n = 1;
        wait_for_rst = 1;
    end
//---------------------------------------------------------------------------
    // instantiate module here
    uart_baudrate_generator u_uart_baudrate_generator (
        .clk              (clk),
        .rst_n            (rst_n),
        .i_brg_divisor    (i_brg_divisor),
        .i_brg_hb_en      (i_brg_hb_en),        // High Baud Rate Enable bit
        .o_tx_pulse       (o_tx_pulse),
        .o_rx_pulse       (o_rx_pulse)
    );
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
    initial begin : driver
        $display ("//=====================================//");
        $display ("//-- [%8t] Simulation Start !!! --//", $time);
        $display ("//=====================================//");
// INITIAL DATA HERE---------------------------------------------------------
        my_item = new();
        my_item.i_brg_divisor = 100;
        my_item.i_brg_hb_en   = 1;
        i_brg_hb_en = my_item.i_brg_hb_en;
        i_brg_divisor = my_item.i_brg_divisor;
        wait_for_rst = 0;
        wait(wait_for_rst);
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
        // CODE HERE
        for (integer i = 0; i < testcases.size(); i++) begin
            run_testcase(testcases[i]);
        end
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
        end_block_flag[0] = 1;
    end
//---------------------------------------------------------------------------
    // OTHER CODE 
//---------------------------------------------------------------------------
    initial begin : monitor
        int tx_clk_cnt;
        int rx_clk_cnt;

        bit tx_checked;
        bit rx_checked;

        int prev_divisor;
        bit prev_hb_en;

        tx_clk_cnt   = 0;
        rx_clk_cnt   = 0;
        tx_checked   = 0;
        rx_checked   = 0;
        prev_divisor = -1;

        wait (rst_n);



        fork
            begin
                forever begin

                    @(posedge clk);

                        if (!rst_n) begin
                            tx_clk_cnt = 0;
                            rx_clk_cnt = 0;
                            tx_checked = 0;
                            rx_checked = 0;
                            continue;
                        end

                        if ( (i_brg_divisor !== prev_divisor) ||
                             (i_brg_hb_en   !== prev_hb_en) ) begin

                            $display("[%0t][MON] BRG Config: divisor=%0d hb=%0d", $time, i_brg_divisor, i_brg_hb_en);
                            tx_clk_cnt = 0;
                            rx_clk_cnt = 0;
                            tx_checked = 0;
                            rx_checked = 0;

                            prev_divisor = i_brg_divisor;
                            prev_hb_en   = i_brg_hb_en;
                        end
                    
                    
                        // TX
                        if (!tx_checked) begin
                            if (o_tx_pulse) begin
                                if (tx_clk_cnt != 0) begin
                                    int exp;
                                    exp = (i_brg_hb_en ? ( (i_brg_divisor + 1) << 2)
                                                      :  ( (i_brg_divisor + 1) << 4)) - 1;

                                    if (tx_clk_cnt !== exp) begin
                                        $error("[%0t][MON][TX] period=%0d exp=%0d",
                                               $time, tx_clk_cnt, exp);
                                        $fatal;
                                    end
                                    else
                                        $display("[%0t][MON][TX] OK period=%0d",
                                                 $time, tx_clk_cnt);

                                    tx_checked = 1;
                                end
                                tx_clk_cnt = 0;
                            end
                            else begin
                                tx_clk_cnt++;
                            end
                        end

                        // RX 
                        if (!rx_checked) begin
                            if (o_rx_pulse) begin
                                if (rx_clk_cnt != 0) begin
                                    int exp;
                                    exp =  i_brg_divisor;

                                    if (rx_clk_cnt !== exp) begin
                                        $error("[%0t][MON][RX] period=%0d exp=%0d",
                                               $time, rx_clk_cnt, exp);
                                        $fatal;
                                    end
                                    else
                                        $display("[%0t][MON][RX] OK period=%0d",
                                                 $time, rx_clk_cnt);

                                    rx_checked = 1;
                                end
                                rx_clk_cnt = 0;
                            end
                            else begin
                                rx_clk_cnt++;
                            end
                        end
                end
            end
            begin
                wait(end_block_flag[0])
                end_block_flag[1] = 1;
            end
        join_any
    end
//---------------------------------------------------------------------------
    initial begin: scoreboard
        wait(end_block_flag[0] & end_block_flag[1]);
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

    task run_testcase(brg_test tc);
        assign_item(tc.divisor, tc.hb);
        drive_item(my_item);

        @(posedge o_tx_pulse);
        repeat (2) @(posedge clk);
        apply_reset();
    endtask


    task drive_item(item it);
        i_brg_divisor = it.i_brg_divisor;
        i_brg_hb_en   = it.i_brg_hb_en;
        $display("[%0t] CFG: divisor=%0d hb=%0d", $time, it.i_brg_divisor, it.i_brg_hb_en);
    endtask

    task  assign_item(input int divisor, input bit hb_en);
        my_item.i_brg_divisor = divisor;
        my_item.i_brg_hb_en   = hb_en;
    endtask

    task apply_reset;
        @(posedge clk);
        rst_n = 0;
        @(posedge clk); 
        #0.1;
        rst_n = 1;
    endtask
//---------------------------------------------------------------------------
endmodule
//===========================================================================


