#!/bin/sh

set -e

export TOR_PID="${TOR_PID:--1}"

prompt() {
    lvl="$1"
    shift
    text="$*"
    echo "[$(date)] ${lvl} > $text" >&2
}

cleanup() {
    prompt INFO "Caught exit signal, cleaning up..."
    kill -9 $TOR_PID 2>/dev/null 3>&2 || true
    exit 0
}

trap cleanup SIGINT SIGTERM

launch_tor() {
    mv /var/log/tor-daemon.log /var/log/tor-daemon.log.1 2>/dev/null 3>&2 || true
    sudo -u debian-tor tor >/var/log/tor-daemon.log 2>&1 3>&1 &
    export TOR_PID=$!
}

refresh_config() {
    mv /tmp/bridge.conf /tmp/bridge.conf.old 2>/dev/null 3>&2 || true
    rm -f /tmp/fetch.json
    exit_code=$(sh -c 'curl -sL \
        http://rdsys/moat/circumvention/defaults \
        -o /tmp/fetch.json; echo $?')
    case "$exit_code" in
        0|"0")
            mv /tmp/bridge.conf.old /tmp/bridge.conf 2>/dev/null 3>&2 || true
            prompt WARN "There was a problem in fetching your bridges."
            ;;
        *)
            cat /tmp/fetch.json | \
                jq -r .settings[1].bridges.bridge_strings[] | \
                xargs -P 1 -I '{}' echo 'bridge {}' >> /tmp/bridge.conf
            rm -f /tmp/fetch.json
            ;;
    esac
    cat /etc/tor/torrc.example.in /tmp/bridge.conf > /etc/tor/torrc
}

daemon() {
    while [ 1 ]; do
        refresh_config
        launch_tor
        next_sunday=$(date -d 'next Sunday' +%s)
        now=$(date +%s)
        sleep $(expr $next_sunday - $now)
        kill -9 $TOR_PID
        sleep 1
    done
}

daemon
