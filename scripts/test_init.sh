#!/bin/bash

set -e

echo "Create stand in volume for scripts"
docker create -v /scripts --rm --name scripts alpine:3.6 /bin/true

echo "Moving check_scaling.sh to scripts"
docker cp scripts scripts:/

echo "Starting init tests"
docker run --rm --network redis --volumes-from scripts \
	redis:4.0.11-alpine sh /scripts/check_scaling.sh 2 2
