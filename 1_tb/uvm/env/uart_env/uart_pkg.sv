//===========================================================================
//-- Author         : Trizrd
//-- Name           : uart_pkg (uart package)
//-- History        : ver.1.00 (26/10/17) 1st release
//--                :
//===========================================================================
`include "uart_if.sv"
package uart_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum bit [1:0] { UART_TX=2'b10, UART_RX=2'b01, UART_TX_RX = 2'b11, UART_NONE = 2'b00 } uart_tx_rx_e;

    typedef enum bit [1:0] { 
        UART_PAR_NONE = 2'b00,
        UART_PAR_ODD = 2'b01,
        UART_PAR_EVEN = 2'b10 
    } uart_par_e;

    typedef enum bit { 
        UART_STOP_1 = 1'b0 ,
        UART_STOP_2 = 1'b1 
    } uart_stop_type_e;

    typedef enum bit { 
        UART_DATA_8 = 1'b0 ,
        UART_DATA_9 = 1'b1 
    } uart_data_type_e;

    `include "uart_cfg.sv"
    `include "uart_item.sv"
    `include "uart_seqr.sv"
    `include "uart_drv.sv"
    `include "uart_mon.sv"
    `include "uart_agt.sv"

endpackage
