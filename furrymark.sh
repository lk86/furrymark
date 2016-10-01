#!/bin/bash
frames=1
runs=0
maxruns=$1

COLS=`tput cols`
LINES=`tput lines`
size=$(($COLS * $LINES))

rands=(`od -A n -t u1 -N 2000 /dev/urandom`)
i=1

os() {
    echo -n "\033[38;5;"${rands[i]}"m"
    eval printf "%.0so҉" {1..$((${rands[i++]} / 3))}
}

frame() {
    [[ $(($RANDOM % 2)) ]] && echo -ne "\033[5m" || echo -ne "\033[25m"
    echo -ne "\033[48;5;"${rands[i]}"m"
    for ((len=0; len < size; len+=${#out}))
    do
        [[ i++ -lt ${#rands[*]}-1 ]] || i=1
        out="$(os i++)"
        echo -ne "$out"
    done
}

trap "check" SIGUSR1
trap "cleanup" SIGTERM SIGINT
trap "cleanup $BASH_COMMAND" ERR

check() {
    [[ $runs -eq 0 ]] || echo "$runs) $frames fps at $COLS * $LINES" >> ./benchmark.log
    [[ $runs -lt $maxruns ]] || cleanup
    frames=1 && let runs++
}

cleanup() {
    kill $pid
    clear
    echo -e "\033[0m $1"
    cat benchmark.log
    exit
}
echo "Starting Benchmark..." > benchmark.log

pid=$$
#while sleep 1
#do
#    /bin/kill -USR1 $pid
#    [[ $? ]] || kill -9 $pid
#done &
watch -tpe -n 1 "kill -USR1 $$" 2>benchmark.log &
pid=$!

while let frames++
do
    frame
done
