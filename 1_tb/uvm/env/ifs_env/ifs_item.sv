//===========================================================================
//-- Author         : manhndd
//-- Name           : ifs_item (interrupt item)
//-- History        : ver.1.00 (26/10/17) 1st release
//===========================================================================
class ifs_item extends uvm_sequence_item;

    bit txifs;  
    bit rxifs;
    bit errifs;
    bit [2:0] changed; // {errifs, rxifs, txifs} values toggled

    `uvm_object_utils_begin(ifs_item)
        `uvm_field_int(txifs,   UVM_ALL_ON)
        `uvm_field_int(rxifs,   UVM_ALL_ON)
        `uvm_field_int(errifs,  UVM_ALL_ON)
        `uvm_field_int(changed, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ifs_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("txifs=%0b rxifs=%0b errifs=%0b (changed=%03b)", txifs, rxifs, errifs, changed);
    endfunction
endclass
