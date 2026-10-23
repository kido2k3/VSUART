#===========================================================================
#-- Author  : kido
#-- Name    : run.sh
#-- History : ver.1.00 (26/10/15) 1st release (not support cov yet)
#--         :
#===========================================================================
#!/bin/bash

comp=1
sim=1
test="base_test"
wave=0
cov=0
tool="vcs"
tool_num=0
seed=$(( $(od -An -N4 -tu4 /dev/urandom) & 0x7FFFFFFF ))
verbosity="UVM_LOW"
log_dir="./log"
src_file="./src_file.f"
tb_file="./tb_file.f"
gen_file=0
# main
main(){
    parse_args "$@"
    if ! [[ -d $log_dir ]]; then
        mkdir $log_dir
    fi

    # *.f file gen
    if [[ gen_file -eq 1 ]]; then
        file_gen
    fi

    if [[ "$tool" == "vcs" ]]; then
        vcs_run
    elif [[ "$tool" == "xrun" ]]; then
        xrun_run
    else
        echo "Unknown tool"
    fi
}
# options scan
parse_args() {
    # option scanning
    while [[ "$1" == -* ]]; do
        case "$1" in
            -vcs)
                tool="vcs"
                ((tool_num++))
                shift
                ;;
            -xrun)
                tool="xrun"
                ((tool_num++))
                shift
                ;;
            -w)
                wave=1
                shift
                ;;
            -cov)
                cov=1
                shift
                ;;
            -c)
                comp=1
                sim=0
                shift
                ;;
            -s)
                comp=0
                sim=1
                shift
                ;;
            -seed)
                seed="$2"
                shift 2
                ;;
            -verb)
                verbosity="$2"
                shift 2
                ;;
            -h)
                show_help
                exit 0
                ;;
            -*)
                echo "Error: unknown option $1"
                show_help
                exit 1
                ;;
        esac
    done
    # check invalid input
    if [[ $tool_num -ge 2 ]]; then
        echo "Error: only one simulator can be selected"
        echo
        show_help
        exit 1
    fi
    # get test name
    if [[ $# -ge 1 ]]; then
        test="$1"
    fi
}
# display help
show_help() {
    echo "Usage: run.sh [simulator] [options] [test_name]"
    echo
    echo "Simulator (default VCS):"
    echo "  -vcs              Run using VCS"
    echo "  -xrun             Run using Xcelium"
    echo
    echo "Options:"
    echo "  -c                Compile only"
    echo "  -s                Simulation only"
    echo "  -w                Enable waveform dump"
    echo "  -cov              Enable coverage"
    echo "  -seed <value>     Specify random seed (default: random)"
    echo "  -verb <value>     Specify verbosity (default: UVM_LOW)"
    echo "  -h                Show this help message"
    echo
    echo "Arguments:"
    echo "  test_name         Test name (default: base_test)"
    echo
    echo "Examples:"
    echo "  ./run.sh"
    echo "  ./run.sh -vcs"
    echo "  ./run.sh -xrun smoke_test"
    echo "  ./run.sh -vcs -seed 12345 random_test"
}
# debug 
show_config() {
    echo "comp          = $comp"
    echo "sim           = $sim"
    echo "seed          = $seed"
    echo "test          = $test"
    echo "wave          = $wave"
    echo "tool          = $tool"
    echo "cov           = $cov"
    echo "verbosity     = $verbosity"
}
# run by vcs 
vcs_run(){
    export DW_LICENSE_WAIT=1
    common_dir="./common_dir"
    # vcs options
    vcs_ops="-licqueue -sverilog -ntb_opts uvm-1.2 +define+SVT_UVM_TECHNOLOGY +define+SYNOPSYS_SV -full64 -debug_access+all"
    # simv options
    simv_ops="+UVM_NO_RELNOTES -licqueue +vcs+lic+wait +UVM_VERBOSITY=$verbosity"
    # add wave
    if [[ $wave -eq 1 ]]; then
        vcs_ops="${vcs_ops} +define+WAVE +define+VCS"
        #simv_ops="${simv_ops} -assert dumpoff +vpdfile+wave.vpd -vcd vcdplus.vcd"
    fi
    # compile
    if [[ $comp -eq 1 ]]; then
        # partition compilation to compile faster
        if ! [[ -d $common_dir ]]; then
            vcs_ops="$vcs_ops -partcomp -partcomp_dir=$common_dir"

        else
            vcs_ops="$vcs_ops -partcomp -partcomp_sharedlib=$common_dir -partcomp_dir=partcomp_dir"
        fi
        
        vcs \
            $vcs_ops \
            -f $src_file \
            -f $tb_file \
            -top tb_vsuart \
            -timescale=100ps/100ps \
            -l $log_dir/vcs.log
        # check
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    fi
    if [[ $sim -eq 1 ]]; then
        simv \
            $simv_ops \
            +ntb_random_seed=${seed} \
            +UVM_TESTNAME=$test \
            -l ${log_dir}/${test}_${seed}.log
    fi
}
# run by xrun
xrun_run(){
    xrun_ops="-nohistory -64bit -sv -uvmhome CDNS-1.2 -nowarn DLCPTH -nowarn SPDUSD -timescale 100ps/100ps -access +rwc"
    # sim options
    xsim_ops="+UVM_NO_RELNOTES +UVM_VERBOSITY=$verbosity -svseed $seed +UVM_TESTNAME=$test"
    # add wave
    if [[ $wave -eq 1 ]]; then
        xrun_ops="${xrun_ops} +define+WAVE +define+XRUN"
    echo "phong"
    fi
    # add coverage
    if [[ $cov -eq 1 ]]; then
        xrun_ops="${xrun_ops} -coverage functional -covoverwrite"
    fi
    # compile + elaborate
    if [[ $comp -eq 1 ]]; then
        xrun \
            $xrun_ops \
            -f $src_file \
            -f $tb_file \
            -top tb_vsuart \
            -elaborate \
            -l $log_dir/xrun_comp.log
        # check
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    fi
    # simulate the elaborated snapshot
    if [[ $sim -eq 1 ]]; then
        xrun \
            $xrun_ops \
            -R \
            $xsim_ops \
            -l ${log_dir}/${test}_${seed}.log
    fi
}

# f file generation for vcs option
file_gen(){
    # reset file
    echo "" > $src_file
    echo "" > $tb_file
    #--- src gen ---
    list=$(find -L ../0_rtl -name "*define*")
    for file in $list; do
        echo $file >> $src_file
    done
    list=$(find -L ../0_rtl/common -type f)
    for file in $list; do
        echo $file >> $src_file
    done
    list=$(find -L ../0_rtl -name "*vsuart*" ! -name "*define*"| awk '{ print length($0), $0 }' | sort -nr | cut -d' ' -f2-)
    for file in $list; do
        echo $file >> $src_file
    done
    #--- tb gen ----
    # incdir
    list=$(find -L ../1_tb/ -type d)
    for dir in $list; do
        echo "+incdir+$dir" >> $tb_file
    done

    # echo "+incdir+../3_third_party/VLSI_COMMON/01_uvm_env/apb_mst_env" >> $tb_file
    list=$(find ../1_tb/ -type f -name "tb_*.sv")
    echo $list >> $tb_file
    # sequence
    list=$(find ../1_tb/uvm/seq -type f -name "*base*" ! -name "*vsuart*")
    for dir in $list; do
        echo $dir >> $tb_file
    done
    list=$(find ../1_tb/uvm/seq -type f -name "vsuart_base*" )
    for dir in $list; do
        echo $dir >> $tb_file
    done
    list=$(find ../1_tb/uvm/seq -type f ! -name "*base*" -name "*vsuart*")
    for dir in $list; do
        echo $dir >> $tb_file
    done
    #test
    list=$(find ../1_tb/uvm/test -type f -name "*base*")
    echo $list >> $tb_file
    list=$(find ../1_tb/uvm/test -type f ! -name "*base*")
    for dir in $list; do
        echo $dir >> $tb_file
    done
}

# ********* main *****
main "$@"
# ********************
