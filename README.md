# Redis Cluster Cache for Docker Swarm

Quick and dirty Redis cluster taking advantage of Redis Sentinel for automatic failover. Persistence is turned off by default.

## Usage

0. Setup docker swarm
1. Create a overlay network:
```
docker network create --attachable --driver overlay redis
```
2. Modify scripts/docker-compose.yml to how you want to deploy the stack.
3. Run `scripts/bootstrap.sh`.
4. Profit!

## Details

A docker service called `redis-zero` is created to serve as the initial master for the redis sentinels to setup. The `redis-look` instances watches the redis sentinels for a master, and connects to `redis-zero` once a master has been decided. Once the dust has settled, remove the `redis-zero` instance and wait for failover to take over so a new redis-master will take over. Use `redis-utils` to reset sentinels so that its metadata is accurate with the correct state.

### Scaling

From now on just scale `redis` to expand the number of slaves or scale `redis-sentinel` to increase the number of sentinels.
