//===========================================================================
//-- File Version    : 1.00
//-- Date            : 25/12/28
//-- Author          : kido
//-- IP Name         : tb_uart_baudrate_generator
//-- History         : ver.1.00 (25/12/28) 1st release
//--
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
    reg    [15 : 0]    i_brg_divisor;
    reg                i_brg_hb_en;            // High Baud Rate Enable reg
    wire              o_tx_pulse;
    wire              o_rx_pulse;
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
    initial begin
        foreach (end_block_flag[i]) begin
            end_block_flag[i] = 0;
        end
    end
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
    initial begin : driver
        $display ("//=====================================//");
        $display ("//-- [%8t] Simulation Start !!! --//", $time);
        $display ("//=====================================//");
// INITIAL DATA HERE---------------------------------------------------------
        my_item = new();
        my_item.i_brg_divisor = 16;
        my_item.i_brg_hb_en   = 0;
        i_brg_hb_en = my_item.i_brg_hb_en;
        i_brg_divisor = my_item.i_brg_divisor;
        wait_for_rst = 0;
        wait(wait_for_rst);
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
        // CODE HERE
        fork
        join
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
        repeat(320) @(posedge clk);
        end_block_flag[0] = 1;
    end
//---------------------------------------------------------------------------
    // OTHER CODE 
//---------------------------------------------------------------------------
    initial begin : monitor
        forever begin
            @(posedge clk);
            if(end_block_flag[0]) begin
                break;
            end
        end
        end_block_flag[1] = 1;
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
//---------------------------------------------------------------------------
endmodule
//===========================================================================