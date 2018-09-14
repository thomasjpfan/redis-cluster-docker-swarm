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

network_ips=$(ifconfig | grep inet | awk '{print $2}' | cut -d ':' -f 2)
master_ip_masked=$(echo $master_ip | cut -d '.' -f 1,2,3)

slave_announce_ip=""

for network_ip in $network_ips; do
	network_ip_masked=$(echo $network_ip | cut -d '.' -f 1,2,3)
	if [ "$network_ip_masked" == "$master_ip_masked" ]; then
		slave_announce_ip="$network_ip"
		break
	fi
done

if [ ! "$slave_announce_ip" ]; then
	echo "Unable to resolve network ip"
	exit 1
fi

echo "Slave ip found: $slave_announce_ip"

sed -i "s/{{ SLAVE_ANNOUNCE_IP }}/$slave_announce_ip/g" /redis/redis.conf

redis-server /redis/redis.conf --slaveof $master_ip $master_port
