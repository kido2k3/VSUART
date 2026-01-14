class apb_transaction extends uvm_sequence_item;

  `uvm_object_utils(apb_transaction)

  //typedef for READ/Write transaction type
  typedef enum bit {
    READ,
    WRITE
  } trans_type;
  rand bit        [31:0] addr;  //Address
  rand bit        [31:0] data;  //Data - For write or read response
  rand trans_type        pwrite;  //command type

  constraint c1 {addr[31:0] inside {[32'd0 : 32'd256]};}
  constraint c2 {data[31:0] inside {[32'd0 : 32'd256]};}

  function new(string name = "apb_transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("pwrite=%h paddr=0x%8h data=0x%8h", pwrite, addr, data);
  endfunction

endclass
