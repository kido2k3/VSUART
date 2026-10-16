//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_base_seq (virtual sequence)
//-- History        : ver.1.00 (26/10/15) 1st release
//--                :
//===========================================================================
class vsuart_base_seq extends uvm_sequence;
    `uvm_object_utils(vsuart_base_seq)

    // sequencer
    clk_rst_seqr r_seqr;

    // sequence
    rst_base_seq r_seq;
    
    // task: during operating reset
    virtual task operate_rst(int interval_time = 8, int rst_time = 60);
        r_seq.req.interval_time = interval_time;
        r_seq.req.rst_time = rst_time;
        r_seq.req.rst_type = rst_item::NO_CLK_PENDING;
        // run
        #1000;
        r_seq.start(r_seqr);
        #1000;
    endtask

    // task: initial reset
    virtual task init_rst(int interval_time = 8, int rst_time = 60);
        r_seq.req.interval_time = interval_time;
        r_seq.req.rst_time = rst_time;
        r_seq.req.rst_type = rst_item::CLK_PENDING;
        // run
        #1000;
        r_seq.start(r_seqr);
        #1000;
    endtask

    function new(string name = "vsuart_base_seq");
        super.new(name);
        r_seq = rst_base_seq::type_id::create("r_seq");
    endfunction

    virtual task body();
        `uvm_info(get_type_name, "Body entered...", UVM_LOW)
        init_rst(13, 10000);
        operate_rst(13, 10000);
        `uvm_info(get_type_name, "Body end...", UVM_LOW)
    endtask
endclass
