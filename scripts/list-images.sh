#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

for IMAGE in $(ls "$SCRIPT_PATH/../dockerfiles" | rev | cut -f 1 -d '/' | cut -f 1 -d '-' | rev); do
    echo "$IMAGE"
done | tr '\n' ' '
