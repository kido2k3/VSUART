class vsuart_csr_rw_access_test extends base_test;
    `uvm_component_utils(vsuart_csr_rw_access_test)

    function new(string name = "vsuart_csr_rw_access_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(vsuart_base_seq::get_type(),
                                  vsuart_csr_rw_access_seq::get_type());
        super.build_phase(phase);
    endfunction

endclass
