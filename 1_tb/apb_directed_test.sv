//--------------------------------------------------------------------
//-- Class: apb_directed_test 
//-- Description: Base class for all APB tests. It builds the common
//--              testbench environment. The actual test sequence is
//--              controlled by derived test classes.
//--------------------------------------------------------------------
class apb_directed_test extends apb_base_test;
  `uvm_component_utils(apb_directed_test)

  //-- Number of transactions to generate
  int sequence_length = 10;


  function new(string name = "apb_directed_test ", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase - Construct the env class and pass virtual interface
  function void build_phase(uvm_phase phase);
  
    //-- Set number of transactions
    uvm_config_db#(int)::set(null, "*", "sequence_length", sequence_length);
    
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("build_phase", "No virtual interface specified for this test instance")
    end

    uvm_config_db#(virtual apb_if)::set(this, "env", "vif", vif);
    

  endfunction


  //-- Run Phase: starts the main sequence
  task run_phase(uvm_phase phase);
    apb_master_directed_sequence seq;
    seq = apb_master_directed_sequence::type_id::create("seq");
    phase.raise_objection(this, "Starting apb_directed_test main phase");

    $display("%t Starting sequence apb_directed_test run_phase", $time);
    seq.start(env.mst_agt.sqr);
    #50ns;

    phase.drop_objection(this, "Finished apb_directed_test in main phase");
  endtask

endclass

