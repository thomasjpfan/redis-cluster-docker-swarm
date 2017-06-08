#!/bin/sh

set -e

sentinels="$1"
slaves="$2"
HOST="-h redis-sentinel -p 26379"

echo "Able to connect to sentinel"
redis-cli $HOST ping

echo "Getting redismaster"
redis-cli $HOST sentinel get-master-addr-by-name redismaster

echo "Make sure there are 2 other sentinels"
master_info=$(redis-cli $HOST sentinel master redismaster)
echo $master_info | grep "num-other-sentinels $sentinels"

echo "Make sure there are 2 slaves"
echo $master_info | grep "num-slaves $slaves"
