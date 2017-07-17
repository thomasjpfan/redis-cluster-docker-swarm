#!/bin/bash

set -e

NUM_OF_SENTINELS=3
NUM_OF_REDIS=3
REDIS_SENTINEL_NAME="redis-sentinel"
REDIS_MASTER_NAME="redismaster"
export TAG=${1:-"master"}

echo "Starting redis-zero"
docker service create --network redis --name redis-zero redis:4.0.0-alpine

echo "Starting services"
docker stack deploy -c scripts/docker-compose.yml cache

until [ "$(docker run --rm --network redis redis-utils:$TAG  \
        $REDIS_SENTINEL_NAME $REDIS_MASTER_NAME \
        value num-other-sentinels)" = "$((NUM_OF_SENTINELS-1))" ]; do
    echo "Sentinels not set up yet - sleeping"
    sleep 2
done

until [ "$(docker run --rm --network redis redis-utils:$TAG \
        $REDIS_SENTINEL_NAME $REDIS_MASTER_NAME \
        value "num-slaves")" = "$NUM_OF_REDIS" ]; do
    echo "Slaves not set up yet - sleeping"
    sleep 2
done

old_master=$(docker run --rm --network redis redis-utils:$TAG \
        $REDIS_SENTINEL_NAME $REDIS_MASTER_NAME value ip)
echo "redis-zero ip is ${old_master}"

echo "Removing redis-zero"
docker service rm redis-zero

until [ "$(docker run --rm --network redis redis-utils:$TAG \
        $REDIS_SENTINEL_NAME $REDIS_MASTER_NAME  value ip)" !=  "$old_master" ]; do
    echo "Failover did not happen yet - sleeping"
    sleep 2
done

echo "Make sure the number of slaves are set"
docker run --rm --network redis redis-utils:$TAG \
$REDIS_SENTINEL_NAME $REDIS_MASTER_NAME reset "num-slaves" "$((NUM_OF_REDIS-1))"
