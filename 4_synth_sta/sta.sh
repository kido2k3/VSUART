#!/bin/bash
#===========================================================================
#-- Author  : kido
#-- Name    : sta.sh
#-- History : ver.1.00 (26/11/08) 1st release
#--         :
#===========================================================================

for t in hs; do
    for c in TT SS FF; do
        TECH=$t CORNER=$c sta -no_splash -exit vsuart_sta.sdc > sta_${t}_$c.log
    done
done
