#!/bin/csh -f

if ($#argv != 2) then
  goto Usage
endif

set TB_TOP = $argv[2]

echo $TB_TOP
echo $argv[1]

if (! -e ./log) then
  mkdir ./log
endif

if ($argv[1] == "-g") then
  echo "Goto GTKwave."
  goto GTKwave
endif

if ($argv[1] == "-m") then
  echo "Goto ModelSim Simulator."
  goto ModelSim
endif

if ($argv[1] == "-v") then
  echo "Goto Vivado simulator."
  goto ViadoSim
endif

if ($argv[1] == "-i") then
  goto Iverilog
endif

#============================================================================
#== usage
#============================================================================
Usage:

echo ""
echo "-----------------------------------------------------------------------"
echo "-- Usage"
echo "-----------------------------------------------------------------------"
echo "--   z_wave tool top"
echo "--     tool   : -m:Model Sim, -v:Vivado Sim, -i:Icarus Verilog"
echo "--     tb_top : TestBench module name"
echo "--"
echo "--     Design :"
echo "--       tb_top"
echo "--        +top"
echo "--         +..."
echo "-----------------------------------------------------------------------"
echo ""

goto END

#============================================================================
#== ModelSim (vlog/vsim)
#============================================================================
ModelSim:

echo "Welcome ModelSim Simulator"
vsim -view $TB_TOP.wlf &
goto END
#============================================================================
#== Viado Simulater (xvlog/xelab/xsim)
#============================================================================
ViadoSim:

echo "Welcome Vivado Simulator"

#---------------------------
#-- Simulation source !!! --
#---------------------------
xsim $TB_TOP -g &

goto END

#============================================================================
#== END
#============================================================================
END:

