FROM redis:4.0.11-alpine

LABEL version="1.0.2"

ENV SENTINEL_QUORUM=2 \
    SENTINEL_DOWN_AFTER=1000 \
    SENTINEL_FAILOVER=1000 \
    REDIS_MASTER_NAME=redismaster \
    REDIS_MASTER=redis-zero \
    REDIS_SENTINEL_NAME=redis-sentinel

RUN apk --no-cache add drill

RUN mkdir -p /redis

WORKDIR /redis

COPY sentinel.conf .
COPY sentinel-entrypoint.sh /usr/local/bin/

RUN chown redis:redis /redis/* && \
    chmod +x /usr/local/bin/sentinel-entrypoint.sh

EXPOSE 26379

ENTRYPOINT ["sentinel-entrypoint.sh"]
