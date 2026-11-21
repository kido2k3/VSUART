//===========================================================================
//-- Author         : kido
//-- Name           : vsuart_irq_w1c_clear_seq (virtual sequence)
//-- History        : ver.1.00 (26/11/21) 1st release
//===========================================================================

class vsuart_irq_w1c_clear_seq extends vsuart_base_seq;
    `uvm_object_utils(vsuart_irq_w1c_clear_seq)
    
    rand apb_mst_base_seq ifs_wr_seq;
    function new(string name = "vsuart_irq_w1c_clear_seq");
        super.new(name);
        ifs_wr_seq = apb_mst_base_seq::type_id::create("ifs_wr_seq");
    endfunction
    
    constraint addr_cstr {
        ifs_wr_seq.seq_item.addr == 16'h0018;
        ifs_wr_seq.seq_item.trans_type == _apb_item::WRITE;
    }
    // task: check interrupt triggered -> clear -> check interrupt not-triggered
    task rxifs_check;
        `uvm_info("SEQ", "check interrupt rx field is triggered", UVM_LOW)
        check_field(ral.IFS.RXIFS, 1);
        check_irq("EV_irq_w1c_clear", 1);
        `uvm_info("SEQ", "clear irq", UVM_LOW)
        clear_irq(ral.IFS.RXIFS);
        check_field(ral.IFS.RXIFS, 0);
        check_irq("EV_irq_w1c_clear", 0);
    endtask
    
    // task: check interrupt flag register
    task ifs_check(bit rxifs=0, bit txifs=0, bit errifs=0);
        check_field(ral.IFS.RXIFS, rxifs);
        check_field(ral.IFS.TXIFS, txifs);
        check_field(ral.IFS.ERRIFS, errifs);
    endtask

    // task: APB write IFS register with different data, strb
    task apb_ifs_wr(int data, int strb);
        assert(ifs_wr_seq.randomize() with{
            seq_item.addr == 'h18;
            seq_item.trans_type == _apb_item::WRITE;
            seq_item.data == data;
            seq_item.strb == strb;
        });
        ifs_wr_seq.start(a_seqr);
    endtask
    virtual task body();
        init_rst(13, 10000);
        `uvm_info("SEQ", "configure registers default then uart enable", UVM_LOW)
        config_default();
        
        `uvm_info("SEQ", "transfer full duplex data", UVM_LOW)
        apb_wr_data();
        uart_wdata();
        `uvm_info("SEQ", "transfer wrong frame", UVM_LOW)
        uart_wdata(1, 1);
        
        `uvm_info("SEQ", "wait for idle state", UVM_LOW)
        //wait_field(ral.STA.FRERR, 1);
        //wait_field(ral.STA.TISTA, 1);
        //wait_field(ral.STA.RISTA, 1);
        check_field(ral.STA.FRERR, 1);

        `uvm_info("SEQ", "check point 1: all ifs must be triggered", UVM_LOW)
        ifs_check(1, 1, 1);
        `uvm_info("SEQ", "check point 2: write with strb=0", UVM_LOW)
        apb_ifs_wr('1, 'h0);
        ifs_check(1, 1, 1);
        `uvm_info("SEQ", "check point 3: clear txifs only", UVM_LOW)
        apb_ifs_wr('h0000_0001, 'b0001);
        ifs_check(1, 0, 1);
        `uvm_info("SEQ", "check point 4: clear rxifs only", UVM_LOW)
        apb_ifs_wr('h0000_0100, 'b0010);
        ifs_check(0, 0, 1);
        `uvm_info("SEQ", "check point 5: clear errifs only", UVM_LOW)
        apb_ifs_wr('h0001_0000, 'b0100);
        ifs_check(0, 0, 0);
    endtask
endclass
