#!/bin/bash
frames=0
runs=0

rm benchmark.log
COLS=`tput cols`
LINES=`tput lines`
RANDOM=$$

fg() {
    echo "\033[38;5;$(($RANDOM % 256))m"
}
    
os() {
    eval printf "%.0so҉" {1..$(($RANDOM%19 + 10))}
}

scree() {
    RANDOM=$RANDOM
    size=$(($COLS * $LINES))
    screen=""
    while [[ ${#screen} -lt $size ]]; do
        col="$(fg)"
        ((size+=${#col}))
        screen="${screen}${col}$(os)"
    done
}

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
    kill $pid 2>/dev/null
    clear
    echo -ne "\033[0m"
    cat benchmark.log
    exit
}

watch -tpe -n 1 "kill -USR1 $$" &
pid=$!

scree
while :
do
    echo -ne $screen 2>/dev/null
    let frames++
    scree
done
