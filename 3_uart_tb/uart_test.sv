//===========================================================================
//-- Author : Trizrd
//-- Name : uart_test
//-- History : ver.1.00 (26/10/16) 1st release
//-- :
//===========================================================================
class uart_base_test extends uvm_test;
 `uvm_component_utils(uart_base_test)

 uart_agent agent;
 uart_cfg cfg;

 function new(string name = "uart_driver", uvm_component parent) ;
 super.new(name, parent);
 endfunction

 function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 cfg = uart_cfg::type_id::create("cfg");
 uvm_config_db#(uart_cfg)::set(this, "agent.*", "u_cfg", cfg); // driver + monitor dung chung
 agent = uart_agent::type_id::create("agent", this);
 endfunction

 // test con doi ham nay de chon sequence khac
 virtual function uart_base_seq make_seq();
 return uart_base_seq::type_id::create("seq", this);
 endfunction

 task run_phase(uvm_phase phase);
 int total = 0;
 phase.raise_objection(this);

 if (agent.mon.n_rx_frames != total || agent.mon.n_tx_frames != total)
 `uvm_error("TEST", $sformatf("so frame sai: sent=%0d rx=%0d tx=%0d",
 total, agent.mon.n_rx_frames, agent.mon.n_tx_frames))
 else
 `uvm_info("TEST", $sformatf("DONE: sent=%0d rx=%0d tx=%0d (xem log DRV vs MON)",
 total, agent.mon.n_rx_frames, agent.mon.n_tx_frames), UVM_NONE)

 phase.drop_objection(this);
 endtask
endclass
