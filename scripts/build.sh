#!/bin/bash

set -e

TAG=${1:-"latest"}

echo "Building redis-look"
docker build -t thomasjpfan/redis-look:$TAG redis-look

echo "Building redis-sentinel"
docker build -t thomasjpfan/redis-sentinel:$TAG redis-sentinel

echo "Building redis-utils"
docker build -t thomasjpfan/redis-utils:$TAG redis-utils
