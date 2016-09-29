#!/bin/bash 
frames=0
runs=0

c='o҉'
[[ $# -gt 0 ]] && c=$1
echo $c
rm benchmark.log
size=$((`tput lines` * `tput cols`))
screen=`eval printf "%.0s$c" {1..$size}`

trap "let frames++" ERR
trap "check" SIGUSR1
trap "cleanup" SIGTERM SIGINT

frame() {
    echo -n $screen
    return 1
}

check() {
    if [[ frames -ne 0 ]]; then
        let runs++
        echo "$runs) $frames fps at `tput cols` * `tput lines`" >> benchmark.log
        frames=0
    fi
}

cleanup() {
    kill $pid
    echo
    cat benchmark.log
    exit
}

echo "Starting benchmark..."
sleep 1
watch -tpe -n 1 "kill -USR1 $$" &
pid=$!

while :; do frame; done
