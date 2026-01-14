class apb_master_directed_sequence extends uvm_sequence #(apb_transaction);

  //-- Register with factory
  `uvm_object_utils(apb_master_directed_sequence)

  //-- Sequence length
  rand int sequence_length;

  //-- Constraint: sequence_length must be less than 100
  constraint length_c {sequence_length inside {[1 : 99]};}

  //-- Flag to track whether config_db provided sequence_length
  bit status = 0;

  //-- Constructor
  function new(string name = "");
    super.new(name);
    assert (this.randomize());  // Randomize when sequence is created
  endfunction

  //-- Main body
  task body();
    apb_transaction tr;


    for (int i = 0; i < sequence_length; i++) begin
      // ---- Write transaction ----
      tr = apb_transaction::type_id::create("tr_write",, get_full_name());
      tr.addr = 32'h0000_0000 + i * 4;
      tr.pwrite = apb_transaction::WRITE;
      tr.data = 32'hA000_0000 + i;

      start_item(tr);
      finish_item(tr);

      // ---- Read transaction ----
      tr = apb_transaction::type_id::create("tr_read",, get_full_name());
      tr.addr = 32'h0000_0000 + i * 4;
      tr.pwrite = apb_transaction::READ;

      start_item(tr);
      finish_item(tr);
    end
  endtask

endclass
