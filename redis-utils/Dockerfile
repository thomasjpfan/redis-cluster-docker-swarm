FROM redis:4.0.2-alpine

RUN apk --no-cache add drill

COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
