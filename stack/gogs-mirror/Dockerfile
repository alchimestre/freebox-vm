FROM alpine:3.24.4
RUN apk add --no-cache curl jq
COPY mirror.sh /usr/local/bin/mirror.sh
ENTRYPOINT ["/usr/local/bin/mirror.sh"]
