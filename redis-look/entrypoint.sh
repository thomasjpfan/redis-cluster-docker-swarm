#!/bin/sh

until [ "$(redis-cli -h $REDIS_SENTINEL_IP -p $REDIS_SENTINEL_PORT ping)" = "PONG" ]; do
    echo "$REDIS_SENTINEL_IP is unavailable - sleeping"
    sleep 1
done

master_info=$(redis-cli -h $REDIS_SENTINEL_IP -p $REDIS_SENTINEL_PORT sentinel get-master-addr-by-name $REDIS_MASTER_NAME)

until [ "$master_info" ]; do
    echo "$REDIS_MASTER_NAME not found - sleeping"
    sleep 1
    master_info=$(redis-cli -h $REDIS_SENTINEL_IP -p $REDIS_SENTINEL_PORT sentinel get-master-addr-by-name $REDIS_MASTER_NAME)
done

master_ip=$(echo $master_info | awk '{print $1}')
master_port=$(echo $master_info | awk '{print $2}')

redis-server /redis/redis.conf --slaveof $master_ip $master_port
