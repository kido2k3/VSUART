//===========================================================================
//-- Author         : manhndd
//-- Name           : ral_cfg 
//-- History        : ver.1.00 (26/10/23) 1st release
//===========================================================================
class ral_cfg extends uvm_object;
    uvm_reg_addr_t base_addr = 0; 
    bit            cov_en    = 1; 

    `uvm_object_utils_begin(ral_cfg)
        `uvm_field_int(base_addr, UVM_ALL_ON)
        `uvm_field_int(cov_en, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ral_cfg");
        super.new(name);
    endfunction
endclass
