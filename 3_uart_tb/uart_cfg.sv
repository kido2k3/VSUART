//===========================================================================

//-- Author         : Trizrd

//-- Name           : uart_cfg (uart configuration)

//-- History        : ver.1.00 (26/10/16) 1st release

//--                :

//===========================================================================

 

class uart_cfg extends uvm_object;

 

    //baudrate from

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

 

    function void update_from_reg (int baudrate, bit [1:0] pdsel , bit stb_sel); // this part will connect with the RAL by using sequence

   

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