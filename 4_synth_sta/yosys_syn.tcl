#===========================================================================
#-- Author  : kido
#-- Name    : yosys_syn.tcl (yosys synthesis file)
#-- History : ver.1.00 (26/10/31) 1st release
#--         :
#===========================================================================
# some variables
set TOP_MODULE vsuart
set LIB_DIR $::env(PDK_ROOT)/sky130B/libs.ref
set LIB $LIB_DIR/sky130_fd_sc_ms/lib/sky130_fd_sc_ms__tt_025C_1v80.lib
set DEBUG 0

if {$DEBUG == 1} {
    yosys debug -on
}
proc debug_print {} {
    global DEBUG
    global LOG
    if {$DEBUG == 1} {
        yosys tee -a $LOG stat -hierarchy -width
    }
}

set LOG "synth.log"
yosys tee -o $LOG log "---------START SYNTHESIS------"
yosys tee -a $LOG log "kido: read rtl"
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_define.v
yosys tee -a $LOG read_verilog ../0_rtl/common/bit_cnt.v
yosys tee -a $LOG read_verilog ../0_rtl/common/edge_det.v
yosys tee -a $LOG read_verilog ../0_rtl/common/cdc_unit_hs.v
yosys tee -a $LOG read_verilog ../0_rtl/common/r1c_reg.v
yosys tee -a $LOG read_verilog ../0_rtl/common/wr_reg.v
yosys tee -a $LOG read_verilog ../0_rtl/common/asc_fifo/fifo_mem.v
yosys tee -a $LOG read_verilog ../0_rtl/common/asc_fifo/wptr_handler.v
yosys tee -a $LOG read_verilog ../0_rtl/common/asc_fifo/synchronizer.v
yosys tee -a $LOG read_verilog ../0_rtl/common/asc_fifo/rptr_handler.v
yosys tee -a $LOG read_verilog ../0_rtl/common/asc_fifo/asc_fifo.v
yosys tee -a $LOG read_verilog ../0_rtl/common/cdc_unit.v
yosys tee -a $LOG read_verilog ../0_rtl/common/w1c_reg.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_tx_p2s_shifter.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx_s2p_shifter.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx_checker.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_tx_parity.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_sync_u2a.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_sync_a2u.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx_start.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_tx_ctrl.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx_fifo.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx_ctrl.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_apb_slv.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_tx_gen.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_tx_brg.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx_brg.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_reg.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_prs.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_ifs.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_tx.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart_rx.v
yosys tee -a $LOG read_verilog ../0_rtl/vsuart.v

yosys tee -a $LOG log "kido: set up top module"
yosys tee -a $LOG hierarchy -check -top ${TOP_MODULE}
debug_print

yosys tee -a $LOG log "kido: flatten"
yosys tee -a $LOG flatten -noscopeinfo
yosys tee -a $LOG clean
debug_print

yosys tee -a $LOG log "kido: first run proc (process)"
yosys tee -a $LOG proc
yosys tee -a $LOG opt
debug_print

yosys tee -a $LOG log "kido: fsm"
yosys tee -a $LOG fsm
yosys tee -a $LOG opt
debug_print

yosys tee -a $LOG log "kido: memory"
yosys tee -a $LOG memory 
yosys tee -a $LOG opt
#yosys tee -a $LOG memory -nomap # further work mapping with memory
debug_print

yosys tee -a $LOG log "kido: opt (optimize)"
debug_print

yosys tee -a $LOG log "kido: read and map to lib cells"
yosys tee -a $LOG read_liberty -lib $LIB
yosys tee -a $LOG techmap
yosys tee -a $LOG opt
yosys tee -a $LOG dfflibmap -liberty $LIB
yosys tee -a $LOG abc -liberty $LIB -D 4250
yosys tee -a $LOG clean

yosys tee -a $LOG log "kido: second opt"
yosys tee -a $LOG opt
yosys tee -a $LOG clean
yosys tee -a $LOG stat -liberty $LIB

#yosys tee -a $LOG select -module vsuart
yosys tee -a $LOG check -mapped
yosys tee -a $LOG write_verilog -noattr -noexpr vsuart_gate.v


