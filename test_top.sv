//--------------------------------------------------------------------
//-- File: test_top.sv
//-- Description: Includes all test-related classes and sequences
//--              for the APB UVM environment. This file is included
//--              by the main apb_top.sv module.
//--------------------------------------------------------------------

//--------------------------------------------------------------------
//-- Core Environment And Sequence Includes
//--------------------------------------------------------------------
 //Include all files

`include "apb_transaction.sv"
`include "apb_sequence.sv"
`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"
`include "apb_master_agent.sv"
`include "apb_master_directed_sequence.sv"
`include "apb_scoreboard.sv"
`include "apb_subscriber.sv"
`include "apb_env.sv"
`include "apb_test.sv"





//--------------------------------------------------------------------
//-- Test Class Includes
//--------------------------------------------------------------------
`include "apb_base_test.sv"
`include "apb_directed_test.sv"



