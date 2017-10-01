#!/bin/bash

set -e

export WORK_DIR="$1"

echo "Starting init tests"
docker run --rm --network redis -v $WORK_DIR/scripts:/scripts \
redis:4.0.2-alpine sh /scripts/check_scaling.sh 2 2


