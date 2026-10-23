//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_cfg (uart configuration)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================
class uart_cfg extends uvm_object;
    //baudrate from
    int unsigned if_clk_freq ;
    int clks_per_bit;
    //data from RAL
    rand uart_data_type_e data_width;
    rand uart_par_e parity_sel;
    //stop bit from RAL

   rand int stop_bit_sel;
   `uvm_object_utils(uart_cfg)
 
    function new(string name = "uart_cfg");
        super.new(name);
    endfunction

    function void set_baudrate(int unsigned baud);
        if (baud == 0) begin
          `uvm_error("CFG", "baudrate = 0, cannot set clks_per_bit")
            return;
        end
        if (if_clk_freq == 0) begin
            `uvm_error("CFG", "if_clk_freq = 0, cannot set clks_per_bit")
        return;
        end

        clks_per_bit = (if_clk_freq + baud / 2) / baud; // sys_clk / baud after that rounded it by adding baud/2 to if_clk_freq
 
        // monitor samples at the middle of a bit -> needs at least 2 clocks per bit
        if (clks_per_bit < 2)
            `uvm_error("CFG", $sformatf("clks_per_bit = %0d is too small (clk=%0d Hz, baud=%0d)",
                              clks_per_bit, if_clk_freq, baud))
    endfunction

    function void update_from_reg (int unsigned baud, bit [1:0] pdsel , bit stb_sel); // this part will connect with the RAL by using sequence
    
    //update baudrate 
    set_baudrate(baud);
    
    //update psel
        case(pdsel)
            2'b00: begin data_width = UART_DATA_9; parity_sel = UART_PAR_NONE; end
            2'b01: begin data_width = UART_DATA_8; parity_sel = UART_PAR_EVEN; end
            2'b10: begin data_width = UART_DATA_8; parity_sel = UART_PAR_ODD;  end
            2'b11: begin data_width = UART_DATA_8; parity_sel = UART_PAR_NONE; end
        endcase
    //update stop bit
        stop_bit_sel = stb_sel ? 2 : 1 ;
    endfunction

 

endclass