#===========================================================================
#-- Author  : kido
#-- Name    : vsuart_sta_div2.sdc (u_clk = sys_clk/2)
#-- History : ver.1.00 (26/11/5) 1st release
#--         :
#===========================================================================

set LIB_DIR $::env(PDK_ROOT)/sky130B/libs.ref
set LIB $LIB_DIR/sky130_fd_sc_ms/lib/sky130_fd_sc_ms__tt_025C_1v80.lib

# read liberty
read_liberty $LIB

# read verilog
read_verilog vsuart_gate.v

# set top
link_design vsuart

# set system clk and pclk
#ns -> max freq = 200MHz
set SYS_CYCLE 5  
#ns -> max freq = 72MHz
set APB_CYCLE 13.8888 

# version of sdc
set sdc_version 2.1

# global unit
set_units -time ns -capacitance pF -resistance kOhm -voltage V -current mA

# create clk
create_clock -name sys_clk -period $SYS_CYCLE [get_ports sys_clk]
create_clock -name pclk -period $APB_CYCLE [get_ports pclk]

# local clk
create_generated_clock -name u_clk -source [get_ports sys_clk] -divide_by 2 [get_pins _7721_/Q]

# async clock domain
set_clock_groups -asynchronous -group {pclk} -group {u_clk}

report_checks

exit 0
