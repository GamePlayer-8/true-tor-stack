#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

for IMAGE in $(ls "$SCRIPT_PATH/../dockerfiles" | rev | cut -f 1 -d '/' | cut -f 1 -d '-' | rev); do
    if ! echo "$IMAGE" | grep -q '\.offline'; then
        echo "$IMAGE"
    fi
done | tr '\n' ' '
