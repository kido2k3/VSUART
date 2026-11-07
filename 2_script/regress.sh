#!/usr/bin/env bash
# Run all regression tests against an existing simulator build.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"
export PATH="$PWD:$PATH"

tool=vcs
seeds=()

while (( $# )); do
    case "$1" in
        -vcs|-xrun) tool=${1#-}; shift ;;
        -seed) seeds+=("$2"); shift 2 ;;
        -h|--help)
            echo "Usage: regress.sh [-vcs|-xrun] [-seed N ...]"
            echo "Run all tests using the existing build. Defaults: VCS, seed 1."
            exit 0 ;;
        *) shift ;;
    esac
done
(( ${#seeds[@]} )) || seeds=(1)

mkdir -p regression log
printf 'test\tseed\tresult\tuvm_error\tuvm_fatal\texit_code\n' > regression/summary.tsv

# classify_result <log> <exit_code> -> sets: result, uvm_err, uvm_fat
# UVM prints "UVM_ERROR : N" / "UVM_FATAL : N" in the final report summary;
# the simulator exit code alone is unreliable (it stays 0 even with UVM errors).
classify_result() {
    local log=$1 rc=$2 line
    uvm_err=''
    uvm_fat=''
    if [[ -s $log ]]; then
        line=$(grep -E '^UVM_ERROR *: *[0-9]+' "$log" | tail -1)
        [[ -n $line ]] && uvm_err=$(grep -oE '[0-9]+' <<< "$line" | tail -1)
        line=$(grep -E '^UVM_FATAL *: *[0-9]+' "$log" | tail -1)
        [[ -n $line ]] && uvm_fat=$(grep -oE '[0-9]+' <<< "$line" | tail -1)
    fi
    if [[ ! -s $log ]]; then
        result='FAIL'
    elif [[ $uvm_err =~ ^[0-9]+$ ]] && (( uvm_err > 0 )); then
        result='FAIL'
    elif [[ $uvm_fat =~ ^[0-9]+$ ]] && (( uvm_fat > 0 )); then
        result='FAIL'
    elif (( rc != 0 )); then
        result='FAIL'
    else
        result='PASS'
    fi
}

passed=0
failed=0
for test_file in ../1_tb/uvm/test/*_test.sv; do
    test=${test_file##*/}
    test=${test%.sv}
    [[ $test == base_test ]] && continue
    for seed in "${seeds[@]}"; do
        echo "Running $test seed=$seed ..."
        rc=0
        bash run.sh "-$tool" -s -seed "$seed" "$test" || rc=$?
        classify_result "log/${test}_${seed}.log" "$rc"
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$test" "$seed" "$result" "${uvm_err:-NA}" "${uvm_fat:-NA}" "$rc" \
            >> regression/summary.tsv
        cp -f "log/${test}_${seed}.log" "regression/${test}_${seed}.log" 2>/dev/null
        if [[ $result == PASS ]]; then
            passed=$((passed + 1))
            echo "  -> PASS"
        else
            failed=$((failed + 1))
            echo "  -> FAIL (uvm_error=${uvm_err:-NA} uvm_fatal=${uvm_fat:-NA} exit_code=$rc)"
        fi
    done
done

if (( failed == 0 )); then
    printf '\nTests passed: %s  Tests failed: %s\n' "$passed" "$failed"
    echo "Summary: $script_dir/regression/summary.tsv"
    exit 0
fi

printf '\nTests passed: %s  Tests failed: %s\n' "$passed" "$failed"
echo "Failed tests:"
grep -P '\tFAIL\t' regression/summary.tsv | cut -f1,2 | paste -sd' ' -
echo "Summary: $script_dir/regression/summary.tsv"
exit 1
