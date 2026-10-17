#===========================================================================
#-- Author : Trizrd
#-- Name : uart_agent
#-- History : ver.1.00 (26/10/16) 1st release
#-- :
#===========================================================================

#!/bin/csh -f
# Compile + elaborate + simulate agent
# ./compile.csh <questa|vcs> [top] [extra_files...] [+plusargs...]
# Khong truyen top -> chi compile.
# Cac tham so bat dau bang '+' duoc truyen cho simulator.

# ---------------- PARSE ARGS ----------------
set POS = ()
set PLUS = ""
foreach a ($argv)
switch ("$a")
 case +*:
 set PLUS = "$PLUS $a"
breaksw
default:
 set POS = ($POS $a)
breaksw
endsw
end

if ($#POS < 1) then
 echo "usage: ./compile.csh <questa|vcs> [top_module] [extra_files...] [+plusargs...]"
 echo "vd: ./compile.csh questa tb_top uart_dut_dummy.sv +UVM_TESTNAME=uart_base_test +WAVE"
 exit 1
endif

set SIM = $POS[1]
set TOP = ""
set FILES = "uart_if.sv uart_pkg.sv"

if ($#POS >= 2) then
 set TOP = $POS[2]
 set TOP_NOEXT = $TOP:r
 if ("$TOP_NOEXT" != "$TOP") then
 set FILES = "$FILES $TOP"
 set TOP = $TOP_NOEXT
endif
endif
if ($#POS >= 3) set FILES = "$FILES $POS[3-]"

# tu dong them <top>.sv neu ton tai va chua co trong FILES
if ("$TOP" != "" && -f $TOP.sv) then
 echo "$FILES" | grep -qw "$TOP.sv"
 if ($status != 0) set FILES = "$FILES $TOP.sv"
endif

set rc = 0

# Questa: tim UVM di kem theo simulator
set UVM_OPT = ""
if ($SIM == questa) then
 set vlog_path = which vlog
 set qhome = $vlog_path:h:h
 set UVM_OPT = "-L mtiUvm"
 set uvm_ver = grep -i '^mtiUvm' $qhome/modelsim.ini | sed 's/.*uvm-//'
 if ("$uvm_ver" != "" && -d $qhome/verilog_src/uvm-$uvm_ver/src) then
 set UVM_OPT = "$UVM_OPT +incdir+$qhome/verilog_src/uvm-$uvm_ver/src"
 echo "UVM macros: uvm-$uvm_ver (cung phien ban voi mtiUvm)"
 else
 echo "WARNING: khong xac dinh duoc phien ban mtiUvm, xem $qhome/modelsim.ini"
endif
endif

# ---------------- COMPILE ----------------
if ($SIM == questa) then
vlib work
vlog -sv $UVM_OPT +incdir+. $FILES -l compile.log
 set rc = $status
else if ($SIM == vcs) then
vlogan -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps +incdir+. $FILES -l compile.log
 set rc = $status
else
 echo "unknown simulator: $SIM (dung questa hoac vcs)"
 exit 1
endif

if ($rc != 0) then
 echo "COMPILE FAILED (xem compile.log)"
 exit 1
endif
echo "COMPILE OK"

# ---------------- ELABORATE ----------------
if ("$TOP" == "") then
 echo "Khong co top module -> bo qua ELABORATE va SIM"
 exit 0
endif

if ($SIM == questa) then
vopt -work work $UVM_OPT $TOP -o ${TOP}_opt +acc -l elab.log
 set rc = $status
else if ($SIM == vcs) then
vcs -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
 -debug_access+all $TOP -o simv -l elab.log
 set rc = $status
endif

if ($rc != 0) then
 echo "ELABORATE FAILED (xem elab.log)"
 exit 1
endif
echo "ELABORATE OK (top = $TOP)"

# ---------------- SIMULATE ----------------
set HAS_TEST = 0
foreach p ($PLUS)
 if ("$p" =~ +UVM_TESTNAME=*) set HAS_TEST = 1
end
if ($HAS_TEST == 0) then
 set PLUS = "$PLUS +UVM_TESTNAME=uart_base_test"
 echo "Khong co UVM_TESTNAME, dung mac dinh uart_base_test"
endif

echo "SIM: $SIM $TOP $PLUS"
if ($SIM == questa) then
vsim -c -work work ${TOP}_opt -l sim.log $PLUS -do "run -all; quit -f"
 set rc = $status
else if ($SIM == vcs) then
./simv -l sim.log $PLUS
 set rc = $status
endif

if ($rc != 0) then
 echo "SIM FAILED, xem sim.log"
 exit 1
endif

grep -Eq 'UVM_(ERROR|FATAL) *: *[1-9]' sim.log
if ($status == 0) then
 echo "SIM FAILED, co UVM_ERROR hoac UVM_FATAL, xem sim.log"
 exit 1
endif

echo "SIM PASSED"