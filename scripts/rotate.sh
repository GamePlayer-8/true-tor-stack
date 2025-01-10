#!/bin/sh

export TOR_PID="${TOR_PID:--1}"
export TRANSPORT_MODE="webtunnel"

prompt() {
    lvl="$1"
    shift
    text="$*"
    echo "[$(date)] ${lvl} > $text" >&2
}

cleanup() {
    exit_code=${1:-0}
    prompt INFO "Caught exit signal, cleaning up..."
    kill -9 $TOR_PID 2>/dev/null 3>&2 || true
    pkill tor 2>/dev/null 3>&2 || true
    exit $exit_code
}

trap cleanup INT TERM

launch_tor() {
    mv /var/log/tor-daemon.log /var/log/tor-daemon.log.1 2>/dev/null 3>&2 || true
    sudo -u debian-tor tor >/var/log/tor-daemon.log 2>&1 3>&1 &
    export TOR_PID=$!
}

get_fetch() {
    case "$1" in
        torbridge-cli)
            rm -f /tmp/fetch-tmp.json
            cat <<EOF'' > /tmp/fetch-tmp.json
{
  "settings": [
    {
      "bridges": {
        "type": "webtunnel",
        "source": "builtin"
      }
    },
    {
      "bridges": {
        "type": "webtunnel",
        "source": "bridgedb",
        "bridge_strings": [
EOF

            exit_code=1
            has_webtunnel="1"
            while [ "$exit_code" != "0" ] || [ "$has_webtunnel" != "0" ]; do
                sleep 4
                exit_code=$(sh -c "TRANSPORT_MODE=webtunnel torbridge-cli 2>/tmp/error.log 3>&2 | \
                    grep 'Your bridges:' -A 3 | grep 'webtunnel' | \
                    xargs -P 1 -I '{}' echo '           \"{}\",' >> /tmp/fetch-tmp.json; echo $?")
                has_webtunnel="$(grep -q 'webtunnel' /tmp/fetch-tmp.json; echo "$?")"
            done

            sed -i '${s/,*$//}' /tmp/fetch-tmp.json

            cat <<EOF'' >> /tmp/fetch-tmp.json
        ]
      }
    }
  ]
}
EOF

            cat /tmp/fetch-tmp.json | tr -d '\n' > /tmp/fetch.json
            ;;
        *)
            exit_code=$(sh -c 'curl -L \
                http://rdsys:8000/moat/circumvention/defaults \
                -o /tmp/fetch.json 2>/tmp/error.log; echo $?')
            ;;
    esac
    echo $exit_code
}

refresh_config() {
    mv /tmp/bridge.conf /tmp/bridge.conf.old 2>/dev/null 3>&2 || true
    rm -f /tmp/fetch.json
    exit_code=$(get_fetch torbridge-cli)
    case "$exit_code" in
        0)
            cat /tmp/fetch.json | \
                jq -r .settings[1].bridges.bridge_strings[] | \
                xargs -P 1 -I '{}' echo 'bridge {}' >> /tmp/bridge.conf
            rm -f /tmp/fetch.json
            ;;
        *)
            mv /tmp/bridge.conf.old /tmp/bridge.conf 2>/dev/null 3>&2 || true
            prompt WARN "There was a problem in fetching your bridges."
            ;;
    esac
    cat /etc/tor/torrc.example.in /tmp/bridge.conf > /etc/tor/torrc
}

daemon() {
    if [ -f "/etc/tor/torrc" ]; then
        launch_tor
    fi
    while [ 1 ]; do
        refresh_config
        sleep 1
        kill -9 $TOR_PID
        pkill tor 2>/dev/null 3>&2 || true
        sleep 1
        launch_tor
        next_sunday=$(date -d 'next Sunday' +%s)
        now=$(date +%s)
        while [ $(date +%s) -gt $(expr $next_sunday - $now) ]; do
            sleep 3
            failures=$(tail -n 3 /var/log/tor-daemon.log | \
                        grep 'general SOCKS server failure' | \
                        wc -l)
            if [ $failures -gt 2 ]; then
                break
            fi
        done
    done
}

daemon
