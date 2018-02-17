#!/bin/bash

set -e

export TAG=${1:-"latest"}

docker stack rm cache
