#!/bin/sh
set -eu

: "${DUCKDNS_TOKEN:?set DUCKDNS_TOKEN}"

ip_query=""
if [ -n "${DUCKDNS_IP:-}" ]; then
  ip_query="&ip=${DUCKDNS_IP}"
fi

response=$(curl -fsS -K - <<EOF
url = "https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}${ip_query}"
EOF
)

if [ "$response" != "OK" ]; then
  echo "DuckDNS update for ${DUCKDNS_SUBDOMAIN} failed: ${response}" >&2
  exit 1
fi
