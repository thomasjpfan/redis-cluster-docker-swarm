#!/bin/bash

set -e

export TAG=${1:-"master"}

echo "Starting init tests"
docker run --rm --network redis -v $PWD/scripts:/scripts \
redis:4.0.0-alpine sh /scripts/check_scaling.sh 2 2


