//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_cfg (uart configuration)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================
class uart_cfg extends uvm_object;
    //uart frequency
    int unsigned if_clk_freq;
    // counter for baudrate gen
    int clks_per_bit;
    //data width
    rand uart_data_type_e data_width;
    // parity mode
    rand uart_par_e parity_sel;
    // stop bit mode
    rand uart_stop_type_e stop_bit_sel;
    // actual baudrate
    rand int unsigned baudrate;
    `uvm_object_utils_begin(uart_cfg)
        `uvm_field_enum(uart_data_type_e, data_width, UVM_ALL_ON)
        `uvm_field_enum(uart_par_e, parity_sel, UVM_ALL_ON)
        `uvm_field_enum(uart_stop_type_e, stop_bit_sel, UVM_ALL_ON)
        `uvm_field_int(baudrate, UVM_ALL_ON)
        `uvm_field_int(if_clk_freq, UVM_ALL_ON)
        `uvm_field_int(clks_per_bit, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_cfg");
        super.new(name);
    endfunction

    constraint baud_range_cstr{
        baudrate inside {[50:921600]};
    }

    constraint mode_cstr{
        data_width == UART_DATA_9 -> parity_sel == UART_PAR_NONE;
    }
    
    function void post_randomize;
        clks_per_bit_cal;
    endfunction
    // function: calculate counter
    function void clks_per_bit_cal();
        clks_per_bit = (if_clk_freq + baudrate / 2) / baudrate; // sys_clk / baud after that rounded it by adding baud/2 to if_clk_freq
 
        // monitor samples at the middle of a bit -> needs at least 2 clocks per bit
        if (clks_per_bit < 2)
            `uvm_fatal("CFG", $sformatf("clks_per_bit = %0d is too small (clk=%0d Hz, baud=%0d)",
                              clks_per_bit, if_clk_freq, baudrate))
    endfunction

 

endclass
