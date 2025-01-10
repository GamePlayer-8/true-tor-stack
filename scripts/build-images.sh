#!/bin/sh

IMG_NAME="${IMG_NAME:-$1}"
shift
IMAGES="${IMAGES:-$*}"

for IMAGE in $IMAGES; do
    docker build -t \
        "$(echo "${IMG_NAME}" | cut -f 1 -d ':')-${IMAGE}:$(echo "${IMG_NAME}" | cut -f 2 -d ':')" \
        -f dockerfiles/Dockerfile-"${IMAGE}" .
done
