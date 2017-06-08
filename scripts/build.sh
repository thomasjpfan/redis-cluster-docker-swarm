#!/bin/bash

set -e

TAG=${1:-"master"}

echo "Building redis-look"
docker build -t redis-look:$TAG redis-look

echo "Building redis-sentinel"
docker build -t redis-sentinel:$TAG redis-sentinel

echo "Building redis-utils"
docker build -t redis-utils:$TAG redis-utils
