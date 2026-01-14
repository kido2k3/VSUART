#!/bin/csh

set DUT_TOP      = "$1"
set TB_TOP   = "$2"
set TESTNAME = "$3"

# =========================================================================
# ==                   Vivado Simulator (xvlog/xelab/xsim)                ==
# =========================================================================

# Make sure to source the Vivado settings script first
# For example: source /opt/Xilinx/Vivado/2024.2/settings64.csh

set PROJECT_ROOT = `dirname $0`/..

mkdir -p "$PROJECT_ROOT/log"
mkdir -p "$PROJECT_ROOT/rep"

echo ""
echo "********************************************************"
printf "APB Protocol Verification - Vivado Sim\n"
printf "Top module:   %-35s \n" "$DUT_TOP"
printf "Test pattern: %-35s \n" "$TESTNAME"
echo "********************************************************"
echo ""


echo "--------------------------------------------------"
echo "----             Compile source               ----"
echo "--------------------------------------------------"

xvlog -sv -f hdl_files --log ../log/xvlog_$DUT_TOP.log

if ($status != 0) then
  echo ""
  echo "##### Compile error   #####"
  exit 1
endif

echo "--------------------------------------------------"
echo "----          Compile UVM testbench           ----"
echo "--------------------------------------------------"

xvlog -sv -i ../env -i ../src -i ../test  ../top.sv -L uvm --log ../log/xvlog_$TB_TOP.log

if ($status != 0) then
  echo ""
  echo "##### Compile testbench error   #####"
  echo ""
  exit 1
endif

echo "--------------------------------------------------"
echo "----             Elaborate source             ----"
echo "--------------------------------------------------"

xelab -debug typical -cc_type bcesfxt $TB_TOP -L uvm --log ../log/xelab_$DUT_TOP.log

if ($status != 0) then
  echo ""
  echo "##### Elaborate error   #####"
  exit 1
endif


echo "--------------------------------------------------"
echo "----              Simulation start            ----"
echo "--------------------------------------------------"

xsim $TB_TOP -R --log "$PROJECT_ROOT/log/xsim_$DUT_TOP.log" --testplusarg "UVM_TESTNAME=$TESTNAME"

if ($status != 0) then
  echo ""
  echo "##### Simulation error   #####"
  echo "Check log: $PROJECT_ROOT/log/xsim_$DUT_TOP.log"
  exit 1
endif

echo "--------------------------------------------------"
echo "----            Code coverage report          ----"
echo "--------------------------------------------------"

xcrg -cc_report ../rep -cc_db work.$TB_TOP -cc_dir ./xsim.codeCov/ -report_format html --log ../log/xcrg_$TB_TOP.log

if ($status != 0) then
  echo ""
  echo "##### Code coverage error   #####"
  echo ""
  exit 1
endif

rm -f *.log
rm -f *.wdb
rm -f *.pb
rm -f *.jou
rm -f *.out
