#!/bin/bash
frames=0
runs=0
maxruns=$1

rm benchmark.log
COLS=`tput cols`
LINES=`tput lines`
RANDOM=$$
i=1

rands=(`od -A n -t u1 -N 2000 /dev/urandom`)

fg() {
    echo "\033[38;5;${rands[i]}m"
}
    
os() {
    eval printf "%.0so҉" {1..${rands[i]}}
}

scree() {
    size=$(($COLS * $LINES))
    screen=${screen:((${#screen}/4)):}
    while [[ ${#screen} -lt $size ]]; do
        col="$(fg)"
        ((size+=${#col}))
        let i++
        [[ $i -ge ${#rands[*]} ]] && i=1
        screen="${screen}${col}$(os)"
    done
}

trap "check" SIGUSR1
trap "cleanup" SIGTERM SIGINT

check() {
    [[ $runs -ne 0 ]] && echo "$runs) $frames fps at $COLS * $LINES" >> ./benchmark.log
    [[ $runs -ge $maxruns ]] && cleanup
    frames=0
    let runs++
}

cleanup() {
    kill $pid 2>/dev/null
    clear
    echo -ne "\033[0m"
    cat benchmark.log
    exit
}

scree

watch -tpe -n 1 "kill -USR1 $$" &
pid=$!

while :
do
    echo -ne $screen 2>/dev/null
    let frames++
    scree
done
