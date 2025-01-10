#!/bin/sh

IMAGE_NAME="${IMAGE_NAME:-$1}"
shift
IMAGES="${IMAGES:-$*}"

for IMAGE in $IMAGES; do
    docker push \
        "$(echo "${IMAGE_NAME}" | cut -f 1 -d ':')-${IMAGE}:$(echo "${IMAGE_NAME}" | cut -f 2 -d ':')"
done
