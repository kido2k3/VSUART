//===========================================================================
//-- Author         : manhndd
//-- Name           : uart_cfg_test (UART disable -> configure -> enable)
//-- History        : ver.1.00 (26/10/22) 1st release
//===========================================================================
class uart_cfg_test extends base_test;
    `uvm_component_utils(uart_cfg_test)

    function new(string name = "uart_cfg_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(), vsuart_uart_cfg_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass
