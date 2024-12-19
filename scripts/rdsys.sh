#!/bin/sh

set -e

export PIDS=""

prompt() {
    lvl="$1"
    shift
    text="$*"
    echo "[$(date)] ${lvl} > $text" >&2
}

cleanup() {
    prompt INFO "Caught exit signal, cleaning up..."
    for pid in $PIDS; do
        kill -9 $pid 2>/dev/null 3>&2 || true
    done
    exit 0
}

trap cleanup SIGINT SIGTERM

daemon_run() {
    $* | tee /var/log/"$1".log | xargs -I '{}' echo "[$1] {}" &
    export PIDS="$PIDS $!"
}

daemon_run rdsys-backend -config /opt/rdsys/config.json
daemon_run rdsys-distributors -name moat -config /opt/rdsys/config.json

for pid in $PIDS; do
    wait $pid
done
