#!/bin/sh

set -x

export PIDS=""

prompt() {
    lvl="$1"
    shift
    text="$*"
    echo "[$(date)] ${lvl} > $text"
}

cleanup() {
    exit_code="${1:-0}"
    prompt INFO "Caught exit signal, cleaning up..."
    for pid in $PIDS; do
        kill -9 $pid 2>/dev/null 3>&2 || true
    done
    exit "$exit_code"
}

trap cleanup INT TERM

daemon_run() {
    $* 2>&1 3>&1 | tee /var/log/"$1".log &
    export PIDS="$PIDS $!"
}

daemon_healthcheck() {
    interval=$1
    shift
    attempts=$1
    shift
    cmd="$*"
    attempt=0
    while [ 1 ]; do
        $cmd 2>&1 3>&1
        exit_code=$?
        if [ "$exit_code" = "0" ]; then
            break
        elif [ $attempt -gt $attempts ]; then
            cleanup 1
        fi
        attempt=$(expr $attempt + 1)
        sleep $interval
    done
}

daemon_run rdsys-backend -config /opt/rdsys/config.json
daemon_healthcheck 5s 10 "sleep 10s"
daemon_run rdsys-distributors -name moat -config /opt/rdsys/config.json

for pid in $PIDS; do
    wait $pid
done
