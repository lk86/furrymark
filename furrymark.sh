#!/bin/bash
frames=0
runs=0

o='o҉'
[[ $# -gt 0 ]] && c=$1
rm benchmark.log
COLS=`tput cols`
LINES=`tput lines`
size=$(($COLS * $LINES))
#screen=$(eval printf "%.0s$o" {1..$size})

fg() {
    echo "\033[38;5;$(($RANDOM % 256))m"
}
    
os() {
    eval printf "%.0s$o" {1..$(($RANDOM % 19))}
}
        
while [[ ${#screen} -lt $size ]]; do
    col="$(fg)"
    ((size+=${#col}))
    screen="${screen}${col}$(os)"
done

trap "check" SIGUSR1
trap "cleanup" SIGTERM SIGINT

check() {
    if [[ frames -ne 0 ]]; then
        let runs++
        echo "$runs) $frames fps at $COLS * $LINES" >> ./benchmark.log
        frames=0
    fi
}

cleanup() {
    kill $pid
    echo
    cat benchmark.log
    exit
}

watch -tpe -n 1 "kill -USR1 $$" &
pid=$!

while :
do
    echo -ne $screen
    let frames++
    i=$(($RANDOM % ${#screen}))
    screen="${screen:0:$i}$(fg)${screen:$i}"
done
