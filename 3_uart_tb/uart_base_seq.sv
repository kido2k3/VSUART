class uart_base_seq extends uvm_sequence #(uart_item);
 `uvm_object_utils(uart_base_seq)

 int frame_num = 5;
 bit inj_parity_err = 0 ;
 bit inj_frame_err = 0 ;

 function new(string name = "uart_base_seq");
 super.new(name);
 endfunction

 task body();
 repeat (frame_num) begin
 req = uart_item::type_id::create("req");
 start_item(req);
 if(!req.randomize() with { //
 uart_dir == UART_RX ;
 parity_error == inj_parity_err;
 frame_error == inj_frame_err;
 })
 `uvm_fatal("SEQ", "fail to create sequence")
 finish_item(req);
 end
 endtask

endclass