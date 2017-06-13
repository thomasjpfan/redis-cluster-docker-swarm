# Redis Cluster Cache for Docker Swarm

[![Build Status](https://travis-ci.org/thomasjpfan/redis-cluster-docker-swarm.svg?branch=master)](https://travis-ci.org/thomasjpfan/redis-cluster-docker-swarm)

Quick and dirty Redis cluster taking advantage of Redis Sentinel for automatic failover. Persistence is turned off by default.

## Usage

0. Setup docker swarm
1. Create a overlay network:
```
docker network create --attachable --driver overlay redis
```
2. Modify scripts/docker-compose.yml to how you want to deploy the stack.
3. Run `scripts/bootstrap.sh`.
```
bash scripts/bootstrap.sh latest
```
4. Profit!

## Details

A docker service called `redis-zero` is created to serve as the initial master for the redis sentinels to setup. The `redis-look` instances watches the redis sentinels for a master, and connects to `redis-zero` once a master has been decided. Once the dust has settled, remove the `redis-zero` instance and wait for failover to take over so a new redis-master will take over. Use `redis-utils` to reset sentinels so that its metadata is accurate with the correct state.

The use of `redis-zero` as a bootstrapping step allows for the `docker-compose.yml` to provide only the long running services:

```yaml
version: '3.1'

services:

  redis-sentinel:
    image: redis-sentinel:v0.1.0-redis-3.2.9
    environment:
      - REDIS_IP=redis-zero
      - REDIS_MASTER_NAME=redismaster
    deploy:
      replicas: 3
    networks:
      - redis

  redis:
    image: redis-look:v0.1.0-redis-3.2.9
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
