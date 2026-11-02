//===========================================================================
//-- Author         : nddm
//-- Name           : vsuart_csr_rw_access_seq (virtual sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//===========================================================================

// Register storage test using standard UVM bit bash plus a UEN sweep.
class vsuart_csr_rw_access_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_csr_rw_access_seq)

    function new(string name = "vsuart_csr_rw_access_seq");
        super.new(name);
    endfunction

    // Compare with the requested value, independently of the predictor mirror.
    virtual task check_uen(input bit [2:0] expected);
        uvm_status_e   access_status;
        uvm_reg_data_t rdata;

        ral.MODE.UEN.write(access_status, expected, .path(UVM_FRONTDOOR), .parent(this));
        if (access_status != UVM_IS_OK)
            `uvm_error("BIT_BASH_UEN", $sformatf("UEN=%03b write failed: %s",
                       expected, access_status.name()))

        ral.MODE.UEN.read(access_status, rdata, .path(UVM_FRONTDOOR), .parent(this));
        if (access_status != UVM_IS_OK)
            `uvm_error("BIT_BASH_UEN", $sformatf("UEN=%03b read failed: %s",
                       expected, access_status.name()))
        else if (rdata !== uvm_reg_data_t'(expected))
            `uvm_error("BIT_BASH_UEN", $sformatf("UEN readback: expected %03b, got 0x%0h",
                       expected, rdata))

        `uvm_info("UEN_SWEEP", $sformatf("Checked UEN=%03b", expected), UVM_LOW)
    endtask

    virtual task body();
        uvm_reg_bit_bash_seq bash_seq;
        uvm_reg_field        sta_fields[$];

        if (ral == null)
            `uvm_fatal("REG_SETUP", "RAL model is null")

        // Keep the RAL mirror updated during frontdoor accesses and bit bash.
        ral.default_map.set_auto_predict(1);

        init_rst(13, 10000);
        uart_disable();

        // Enable compare (UVM_CHECK) for all fields in STA register to run bit-bash test
        ral.STA.get_fields(sta_fields);
        foreach (sta_fields[i]) begin
            sta_fields[i].set_compare(UVM_CHECK);
        end
        
        // Skip UEN in standard bit bash: other registers need UART disabled.
        ral.MODE.UEN.set_compare(UVM_NO_CHECK);

        // 4. Create and execute uvm_reg_bit_bash_seq across the whole RAL model       
        bash_seq = uvm_reg_bit_bash_seq::type_id::create("bash_seq");
        bash_seq.model = ral;
        bash_seq.start(null, this);

        for (int unsigned pattern = 0; pattern < 8; pattern++) begin
            check_uen(3'(pattern));
        end
        uart_disable();

        //return default compare type for STA and MODE.UVN
        foreach (sta_fields[i]) begin
            sta_fields[i].set_compare(UVM_NO_CHECK);
        end
        ral.MODE.UEN.set_compare(UVM_CHECK);

        `uvm_info("REG_DONE", "RAL bit-bash sequence completed", UVM_LOW)
    endtask
endclass
