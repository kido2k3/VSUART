//===========================================================================
//-- Author         : trizrd
//-- Name           : uart_base_seq (uart base sequence)
//-- History        : ver.1.00 (26/10/24) 1st release
//--                :
//===========================================================================
class uart_base_seq extends uvm_sequence #(uart_item);
    // sequence item for randomize
    rand uart_item seq_item;
    `uvm_object_utils(uart_base_seq)
    function new(string name = "uart_base_seq");
        super.new(name);
        seq_item = uart_item::type_id::create("seq_item");
    endfunction 
    

    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        start_item(seq_item);
        finish_item(seq_item);
        get_response(rsp);
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
