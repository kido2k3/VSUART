#===========================================================================
#-- Author  : kido
#-- Name    : vsuart_sta_div2.sdc (u_clk = sys_clk/2)
#-- History : ver.1.00 (26/11/5) 1st release
#--         :
#===========================================================================
# some variables
foreach v {TECH CORNER} {
    if {![info exists ::env($v)]} {
        puts "ERROR: environment variable $v is not set"
        exit 1
    }
}
set tech   $::env(TECH)
set corner $::env(CORNER)
set corners [dict create \
    TT __tt_025C_1v80 \
    SS __ss_100C_1v60 \
    FF __ff_n40C_1v95 \
]
if {![dict exists $corners $corner]} {
    puts "ERROR: unknown corner $corner (known: [dict keys $corners])"
    exit 1
}

set TOP_MODULE vsuart
set LIB_DIR $::env(PDK_ROOT)/sky130B/libs.ref

set suffix [dict get $corners $corner]
set LIB    ${LIB_DIR}/sky130_fd_sc_${tech}/lib/sky130_fd_sc_${tech}${suffix}.lib
set GATE   vsuart_gate_${tech}_${corner}.v
set LOG    sta_${tech}_${corner}.log

foreach f [list $LIB $GATE] {
    if {![file exists $f]} {
        puts "ERROR: $f not found"
        exit 1
    }
}

# set system clk and pclk
set SYS_CYCLE 7     ;# ns -> 200 MHz
set APB_CYCLE 7.8    ;# ns -> 100 MHz

# read liberty
read_liberty $LIB

# read verilog
read_verilog $GATE

# set top
link_design $TOP_MODULE

# global unit
set_units -time ns -capacitance pF -resistance kOhm -voltage V -current mA


# create clk
create_clock -name sys_clk -period $SYS_CYCLE [get_ports sys_clk]
create_clock -name pclk -period $APB_CYCLE [get_ports pclk]

# local clk
#create_generated_clock -name u_clk -source [get_ports sys_clk] -divide_by 1 [get_nets u_clk]

# async clock domain
set_clock_groups -asynchronous -group {pclk} -group {sys_clk}

# clock jitter
set_clock_uncertainty -setup 0.3 [all_clocks]
set_clock_uncertainty -hold  0.1 [all_clocks]

# input delay
set_input_delay -clock pclk -max 2.0 \
    [get_ports {i_paddr[*] i_psel i_penable i_pwrite i_pwdata[*] i_pstrb[*]}]

set_input_delay -clock pclk -min 0.5 \
    [get_ports {i_paddr[*] i_psel i_penable i_pwrite i_pwdata[*] i_pstrb[*]}]

# output delay

set_output_delay -clock pclk -max 0.0 \
    [get_ports {o_pready o_prdata[*] o_pslverr o_rxifs o_txifs o_errifs}]

set_output_delay -clock pclk -min 0.0 \
    [get_ports {o_pready o_prdata[*] o_pslverr o_rxifs o_txifs o_errifs}]

check_setup -verbose

puts "kido: all violated set up time"
#report_checks \
#    -path_delay max \
#    -slack_max 0.0 \
#    -group_path_count 100000 \
#    -format full_clock_expanded \
#    -fields {slew cap fanout} \
#    -digits 4 
report_checks \
    -path_delay max \
    -group_path_count 100000 \
    -format full_clock_expanded \
    -fields {slew cap fanout} \
    -digits 4 
puts "kido: all violated hold time"
#report_checks \
#    -path_delay min \
#    -slack_max 0.0 \
#    -group_path_count 100000 \
#    -format full_clock_expanded 
report_checks \
    -path_delay min \
    -group_path_count 100000 \
    -format full_clock_expanded 
# slack for hold time
puts "kido: SUMMARY"
report_worst_slack -min
report_tns -min
report_wns -min
# slack for setup time
report_worst_slack -max
report_tns -max
report_wns -max

