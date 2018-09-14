#!/bin/sh

REDIS_SENTINEL_NAME="$1"
REDIS_MASTER_NAME="$2"
shift 2

sentinel_ips=$(drill tasks.$REDIS_SENTINEL_NAME | grep tasks.$REDIS_SENTINEL_NAME | tail -n +2 | awk '{print $5}')
until [ "$sentinel_ips" ]; do
	sleep 1
	sentinel_ips=$(drill tasks.$REDIS_SENTINEL_NAME | grep tasks.$REDIS_SENTINEL_NAME | tail -n +2 | awk '{print $5}')
done

get_value() {
	ip="$1"
	port="$2"
	master_name="$3"
	key="$4"
	echo $(redis-cli -h $ip -p $port sentinel master $master_name | grep -A 1 $key | tail -n1)
}

case ${1} in
reset)
	shift 1
	key="$1"
	target="$2"
	for ip in $sentinel_ips; do
		echo "Reseting sentinel for ip: ${ip}"
		redis-cli -h $ip -p 26379 sentinel reset $REDIS_MASTER_NAME
		until [ "$(get_value $ip 26379 $REDIS_MASTER_NAME $key)" = "$target" ]; do
			echo "$key not equal to $target - sleeping"
			sleep 2
		done
	done
	;;
value)
	shift 1
	key="$1"
	first_ip=$(echo $sentinel_ips | cut -d " " -f 1)
	value=$(get_value $first_ip 26379 $REDIS_MASTER_NAME $key)
	for ip in $sentinel_ips; do
		k_value="$(get_value $ip 26379 $REDIS_MASTER_NAME $key)"
		if [ "$k_value" != "$value" ]; then
			echo "-1"
			exit 1
		fi
	done
	echo "$value"
	;;
show)
	shift 1
	key="$1"
	for ip in $sentinel_ips; do
		k_value="$(get_value $ip 26379 $REDIS_MASTER_NAME $key)"
		echo "${ip}: ${k_value}"
	done
	;;
esac
