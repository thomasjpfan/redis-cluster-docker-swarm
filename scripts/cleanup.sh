#!/bin/bash

set -e

export TAG=${1:-"master"}

docker stack rm cache
