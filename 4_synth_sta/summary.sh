#!/bin/bash
# ===========================================================
# Author : kido
# Name   : summary.sh
# Purpose: Summarize synthesis area and STA violations
# ===========================================================

TECHS=(hs)
CORNERS=(TT SS FF)

printf "%-35s | %15s | %15s\n" \
    "Name" "Area (um2)" "Violated count"

printf '%s\n' "--------------------------------------------------------------------------"

for tech in "${TECHS[@]}"; do
    for corner in "${CORNERS[@]}"; do

        NAME="vsuart_gate_${tech}_${corner}.v"
        SYNTH_LOG="synth_${tech}_${corner}.log"
        STA_LOG="sta_${tech}_${corner}.log"

        # Extract chip area
        if [[ -f "$SYNTH_LOG" ]]; then
            AREA=$(awk -F': ' "/Chip area for module/ {print \$2; exit}" "$SYNTH_LOG")
        else
            AREA="N/A"
        fi

        # Count violated timing paths
        if [[ -f "$STA_LOG" ]]; then
            VIOLATED=$(grep -cF "slack (VIOLATED)" "$STA_LOG")
        else
            VIOLATED="N/A"
        fi

        [[ -z "$AREA" ]] && AREA="N/A"

        printf "%-35s | %15s | %15s\n" \
            "$NAME" "$AREA" "$VIOLATED"

    done
done

printf '%s\n' "--------------------------------------------------------------------------"
