#!/bin/csh -f
#------------------------------------------------
set VIVADO_DIR = "/mnt/d/phong/li_env/01_download/Vivado/Vivado/2024.2"
set PRJ_DIR = "/mnt/d/phong/li_env/VSUART"
#------------------------------------------------
if ($#argv < 2) then
  goto Usage
endif
#------------------------------------------------
set TB_TOP = $argv[2]
echo $TB_TOP
echo $argv[1]
if ( $#argv >= 3) then
    set CVR_NAME = "$argv[3]"
else
    set CVR_NAME = "DB0"
endif
echo $CVR_NAME
#------------------------------------------------
if (! -e $PRJ_DIR/log) then
  mkdir $PRJ_DIR/log
else
  rm $PRJ_DIR/log/* -r
endif
#------------------------------------------------
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
echo "--   zgo_sim tool top"
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
#------------------------
#-- Compile source !!! --
#------------------------
vlib work
vmap work work
vlog -lint -sv -f filelist.f -l ./log/vlog_$TB_TOP.log -timescale 1ns/1ps
if ($status != 0) then
  echo ""
  echo "##### Compile error !!! #####"
  echo ""
  goto END
endif
#-----------------------------------------
#-- Elaborate and Simulation source !!! --
#-----------------------------------------
# vcd files $TB_TOP.vcd && \
# vcd add 
# vcd add -file $TB_TOP.vcd /*; 
set VSIM_TRANS = "vcd file $TB_TOP.vcd; vcd add -file $TB_TOP.vcd /*; run -all; quit;"
# SIM
vsim -c $TB_TOP -do "$VSIM_TRANS" -l ./log/vsim_$TB_TOP.log +dumpports+nocollapse
# translate into wlf
vcd2wlf $TB_TOP.vcd $TB_TOP.wlf
if ($status != 0) then
  echo ""
  echo "##### Elaborate and Simulation error !!! #####"
  echo ""
  goto END
endif
goto END
#============================================================================
#== Viado Simulator (xvlog/xelab/xsim)
#============================================================================
ViadoSim:
echo "Welcome Vivado Simulator"
if ("$PATH" =~ *"Vivado"*) then
else
  echo "NOT SOURCE SETTINGS FILE YET"
  goto END
endif
#------------------------
#-- Compile source !!! --
#------------------------
find $PRJ_DIR -maxdepth 2 -name "*.v" > $PRJ_DIR/filelist.f
find $PRJ_DIR -maxdepth 2 -name "*.sv" >> $PRJ_DIR/filelist.f
sed -i '/tb\.sv/d' $PRJ_DIR/filelist.f
xvlog -f $PRJ_DIR/2_script/vxlog.f -f $PRJ_DIR/filelist.f
if ($status != 0) then
  echo ""
  echo "##### Compile error !!! #####"
  echo ""
  goto END
endif
#--------------------------
#-- Elaborate source !!! --
#--------------------------
xelab $TB_TOP -cc_db $CVR_NAME -cov_db_name $CVR_NAME -f $PRJ_DIR/2_script/xelab.f
if ($status != 0) then
  echo ""
  echo "##### Elaborate error !!! #####"
  echo ""
  goto END
endif
#---------------------------
#-- Simulation source !!! --
#---------------------------
xsim $TB_TOP -R --log ./log/xsim.log 
if ($status != 0) then
  echo ""
  echo "##### Simulation error !!! #####"
  echo ""
  goto END
endif
goto END
#============================================================================
#== Icarus Verilog (iverilog/vvp/gtkwave)
#============================================================================
Iverilog:
echo "Welcome Iverilog Simulator"
#--------------------------------------
#-- Compile and Elaborate source !!! --
#--------------------------------------
iverilog -o $TB_TOP.out -W all -c filelist.f
if ($status != 0) then
  echo ""
  echo "##### Compile and Elaborate error !!! #####"
  echo ""
  goto END
endif
#---------------------------
#-- Simulation source !!! --
#---------------------------
vvp -l ./log/vvp_$TB_TOP.log $TB_TOP.out
if ($status != 0) then
  echo ""
  echo "##### Simulation error !!! #####"
  echo ""
  goto END
endif
goto END
#============================================================================
#== END
#============================================================================
END:
# find ./log -maxdepth 1 -name "*.log" > $PRJ_DIR/log_list.txt
# foreach f ( `cat log_list.txt` )
#     sed '/^$/d' "$f" > "$f.tmp"
#     mv "$f.tmp" "$f"
# end
# rm -f $PRJ_DIR/log_list.txt