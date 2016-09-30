#!/bin/bash
frames=0
runs=0
maxruns=$1

COLS=`tput cols`
LINES=`tput lines`
size=$(($COLS * $LINES))

rands=(`od -A n -t u1 -N 2000 /dev/urandom`)
i=1

os() {
    echo -n "\033[38;5;"${rands[i]}m
    eval printf "%.0so҉" {1..$((${rands[i++]} / 3))}
}

frame() {
    for ((len=0; len < size; len+=${#out}))
    do
        [[ i++ -ge ${#rands[*]} ]] && i=1
        out="$(os i++)"
        echo -ne "$out"
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
rm benchmark.log

watch -tpe -n 1 "kill -USR1 $$" &
pid=$!

while :
do
    frame 2>/dev/null
    let frames++
done
