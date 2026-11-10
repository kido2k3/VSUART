//===========================================================================
//-- Author         : manhndd
//-- Name           : irq_item (single-line interrupt transaction item)
//-- History        : ver.1.00 (26/11/07) Single-line reusable IRQ item
//===========================================================================
class irq_item extends uvm_sequence_item;
    string    irq_name;    // "TX", "RX", "ERR"
    bit       level;       // 0 or 1
    time      timestamp;

    `uvm_object_utils_begin(irq_item)
        `uvm_field_string(irq_name,  UVM_ALL_ON)
        `uvm_field_int   (level,     UVM_ALL_ON)
        `uvm_field_int   (timestamp, UVM_ALL_ON | UVM_TIME)
    `uvm_object_utils_end

    function new(string name = "irq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("[%s_IRQ] level=%0b @%0t", irq_name, level, timestamp);
    endfunction
endclass



