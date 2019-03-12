#!/usr/bin/env bash
#~math with timestamps
#~it seems to work idk about multiplying hours by nano seconds..? 
#~it can also do logic -- <,>,<=,>=,==,!= etc...
#~but it cand to carrots^ /powers atm (or ever?)


#~ config ~#


#~ functions ~#

_t2s() {
    #~converts HH:MM:SS.nnn.. to SSSSS.nnn.. for math
    printf '%s' "$1" | awk -F: '{ printf "%.10f", ($1 * 3600) + ($2 * 60) + $3 }'
}

_sit() {
    #~converts SSSSS.nnn.. back to HH:MM:SS.nnn.. (thnx modulus ur a babe)
    #~accepts one arg 
    nanoSeconds=${1##*.}
    echo $nanoSeconds
    seconds=$((${1%.*} % 60))
    echo $seconds
    tMinutes=$((${1%.*} / 60))
    echo $tMinutes
    minutes=$(($tMinutes % 60))
    echo $minutes
    hours=$(($tMinutes / 60))
    echo $hours
    printf '%s:%s:%.10f' "$hours" "$minutes" "$seconds.$nanoSeconds"
}

_s2t() {
    #~converts SSSSS.nnn.. back to HH:MM:SS.nnn.. (thnx modulus ur a babe)
    #~accepts one arg 
    seconds=$(echo "scale=0;$1 % 60" | BC_LINE_LENGTH=0 bc -l)
    tMinutes=$(echo "scale=0;$1 / 60" | BC_LINE_LENGTH=0 bc -l)
    minutes=$(echo "scale=0;$tMinutes % 60" | BC_LINE_LENGTH=0 bc -l)
    hours=$(echo "scale=0;$tMinutes / 60" | BC_LINE_LENGTH=0 bc -l)
    printf '%s:%s:%.10f' "$hours" "$minutes" "$seconds"
}

_mathTime() {
    #~wrapper for _mathTimeActual
    #~reason is to change a string "hello there" into arguments "hello" "there" without the user needing to quote each arg
    #~accepts 1 arg (string) operators need to be padded by spaces as thats how theyre parsed
    #~ie. "12:23:4.46 + ( 1:4:54.432 - 2:14:10.23 )"
    set -f
    _mathTimeActual $@
    set +f
}

_mathTimeActual() {
    #~takes time math and evaluates
    #argArray=($1)
    unset bcArgs
    unset logic
    unset timeBool
    #for i in ${argArray[@]}; do
    while [ "$1" != "" ]; do
        echo Item:$1
        case "$1" in
            \+|\-|\%|\(|\))
                bcArgs+="$1"
                echo "Type:Operator(basic)"
                ;;
            \<|\<\=|\>|\>\=|\=\=|\!\=|\&\&|\|\|)
                bcArgs+="$1"
                logic=1
                echo "Type:Logic"
                ;;
            /)
                bcArgs+="*3600/"
                echo "Type:/"
                ;;
            \*)
                bcArgs+="/3600*"
                echo "Type:*"
                ;;
            ^)
                #bcArgs+="^("
                #shift
                #~assumes op num op num pattern etc..
                #~TODO test for ( before number after ^?
                #bcArgs+="$(_t2s "$1")/3600)"
                #break
                echo "'^' is not supported at this time"
                echo "replacing with '+'"
                bcArgs+="+"
                ;;
            *:*:*)
                bcArgs+="$(_t2s "$1")"
                echo "Type:time"
                ;;
            *)
                echo "Type:other"
                #shouldnt be anything here
                ;;
        esac
        shift
    done

    sumSec=$(echo "scale=0;$bcArgs" | BC_LINE_LENGTH=0 bc -l)
    sum=$(_s2t "$sumSec") #~bc splits massive # into multiple lines -- removes them
    if [ "$logic" == 1 ]; then 
        [ "$(printf '%.0f' "${sum##*:}")" == 1 ] && timeBool="TRUE" || timeBool="FALSE"
    fi
    printf '\nSUM:\n%s\n%s\n' "$sum" "$timeBool"
}

#~script start ~#
[ -n "$1" ] && equ="$@" || read -p "Enter Equation: " equ
_mathTime "$equ"
