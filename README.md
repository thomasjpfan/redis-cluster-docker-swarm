# Redis Cluster Cache for Docker Swarm

[![CircleCI](https://circleci.com/gh/thomasjpfan/redis-cluster-docker-swarm/tree/master.svg?style=svg)](https://circleci.com/gh/thomasjpfan/redis-cluster-docker-swarm/tree/master)

Quick and dirty Redis cluster taking advantage of Redis Sentinel for automatic failover. Persistence is turned off by default.

## Usage

0. Setup docker swarm
1. Create a overlay network:

```bash
docker network create --attachable --driver overlay redis
```

2. Modify scripts/docker-compose.yml to how you want to deploy the stack.
3. Run `scripts/bootstrap.sh`.

```bash
bash scripts/bootstrap.sh latest
```

4. Connect to with redis-cli

```bash
docker run --rm --network redis -ti redis:4.0.11-alpine redis-cli -h redis
```

To access the redis cluster outside of docker, port 6379 needs to be expose. This can be done by adding ports to the docker-compose file:

```yaml
...
  redis:
    image: thomasjpfan/redis-look
    ports:
      - "6379:6379"
...
```

## Details

A docker service called `redis-zero` is created to serve as the initial master for the redis sentinels to setup. The `redis-look` instances watches the redis sentinels for a master, and connects to `redis-zero` once a master has been decided. Once the dust has settled, remove the `redis-zero` instance and wait for failover to take over so a new redis-master will take over. Use `redis-utils` to reset sentinels so that its metadata is accurate with the correct state.

The use of `redis-zero` as a bootstrapping step allows for the `docker-compose.yml` to provide only the long running services:

```yaml
version: '3.1'

services:

  redis-sentinel:
    image: thomasjpfan/redis-sentinel
    environment:
      - REDIS_IP=redis-zero
      - REDIS_MASTER_NAME=redismaster
    deploy:
      replicas: 3
    networks:
      - redis

  redis:
    image: thomasjpfan/redis-look
    environment:
      - REDIS_SENTINEL_IP=redis-sentinel
      - REDIS_MASTER_NAME=redismaster
      - REDIS_SENTINEL_PORT=26379
    deploy:
      replicas: 3
    networks:
      - redis

networks:
  redis:
    external: true

```

### Scaling

From now on just scale `redis` to expand the number of slaves or scale `redis-sentinel` to increase the number of sentinels.
