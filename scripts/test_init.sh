#!/bin/bash

set -e

export WORK_DIR="$1"

echo "Create stand in volume for scripts"
docker create -v /scripts --name scripts alpine:3.6 /bin/true

echo "Moving check_scaling.sh to scripts"
docker cp "${WORK_DIR}/scripts/check_scaling.sh" scripts:/scripts

echo "Starting init tests"
docker run --rm --network redis --volumes-from scripts \
redis:4.0.2-alpine sh /scripts/check_scaling.sh 2 2


