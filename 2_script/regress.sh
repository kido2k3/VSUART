#!/usr/bin/env bash
# Run all regression tests against an existing simulator build.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"
export PATH="$PWD:$PATH"

tool=vcs

while (( $# )); do
    case "$1" in
        -vcs|-xrun) tool=${1#-}; shift ;;
        -h|--help)
            echo "Usage: regress.sh [-vcs|-xrun]"
            echo "Run all tests once with a random seed using the existing build. Default: VCS."
            exit 0 ;;
        *) shift ;;
    esac
done

# newest log of <test> written after the stamp file (run.sh names it <test>_<seed>.log)
find_log() {
    find log -maxdepth 1 -name "${1}_[0-9]*.log" -newer regression/.stamp \
        -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-
}

mkdir -p regression log
printf 'test\tseed\tresult\tuvm_error\tuvm_fatal\texit_code\n' > regression/summary.tsv

# uvm_count <log> <ERROR|FATAL> -> prints the count of that severity
# Use the report summary line "UVM_ERROR : N" when present. The summary is
# printed at UVM_LOW, so with -verb UVM_NONE it is missing; then count the
# message lines ("UVM_ERROR <file>(<line>) @ ..."), which print at any verbosity.
uvm_count() {
    local log=$1 sev=$2 line
    line=$(grep -E "^UVM_${sev} *: *[0-9]+" "$log" | tail -1 || true)
    if [[ -n $line ]]; then
        grep -oE '[0-9]+' <<< "$line" | tail -1
    else
        grep -cE "^UVM_${sev} +[^ :]" "$log" || true
    fi
}

# classify_result <log> <exit_code> -> sets: result, uvm_err, uvm_fat
# The simulator exit code alone is unreliable (it stays 0 even with UVM errors).
classify_result() {
    local log=$1 rc=$2
    uvm_err=''
    uvm_fat=''
    if [[ -s $log ]]; then
        uvm_err=$(uvm_count "$log" ERROR)
        uvm_fat=$(uvm_count "$log" FATAL)
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
fail_list=()
for test_file in ../1_tb/uvm/test/*_test.sv; do
    test=${test_file##*/}
    test=${test%.sv}
    [[ $test == base_test ]] && continue
    echo "Running $test ..."
    touch regression/.stamp
    rc=0
    bash run.sh "-$tool" -verb UVM_NONE "$test" || rc=$?
    log=$(find_log "$test")
    seed=NA
    [[ -n $log ]] && { seed=${log##*_}; seed=${seed%.log}; }
    classify_result "${log:-/dev/null}" "$rc"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$test" "$seed" "$result" "${uvm_err:-NA}" "${uvm_fat:-NA}" "$rc" \
        >> regression/summary.tsv
    [[ -n $log ]] && cp -f "$log" regression/
    if [[ $result == PASS ]]; then
        passed=$((passed + 1))
        echo "  -> PASS"
    else
        failed=$((failed + 1))
        fail_list+=("$test")
        echo "  -> FAIL (uvm_error=${uvm_err:-NA} uvm_fatal=${uvm_fat:-NA} exit_code=$rc)"
    fi
done

total=$((passed + failed))
if (( total > 0 )); then
    pass_rate=$(awk -v p="$passed" -v t="$total" 'BEGIN { r = 100 * p / t; if (r == int(r)) printf "%d", r; else printf "%.2f", r }')
else
    pass_rate=0
fi

echo
echo "==================== Regression Summary ===================="
printf '%-12s: %s\n' "Total Tests" "$total"
printf '%-12s: %s\n' "Passed" "$passed"
printf '%-12s: %s\n' "Failed" "$failed"
echo
printf '%-12s: %s%%\n' "Pass Rate" "$pass_rate"
if (( failed > 0 )); then
    echo
    echo "Failed tests:"
    for f in "${fail_list[@]}"; do
        echo "  - $f"
    done
fi
echo "============================================================"
echo "Summary: $script_dir/regression/summary.tsv"
(( failed == 0 ))
