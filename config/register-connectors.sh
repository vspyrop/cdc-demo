#!/bin/sh
set -eu

connect_url=http://connect:8083
attempt=0

until curl -fsS "$connect_url/connectors" >/dev/null; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    echo "Kafka Connect did not become ready after 60 attempts" >&2
    exit 1
  fi
  sleep 2
done

curl -fsS -X PUT \
  -H 'Content-Type: application/json' \
  --data-binary @/config/postgres-source.json \
  "$connect_url/connectors/postgres-source/config"
printf '\nRegistered PostgreSQL CDC source connector.\n'

curl -fsS -X PUT \
  -H 'Content-Type: application/json' \
  --data-binary @/config/iceberg-sink.json \
  "$connect_url/connectors/iceberg-sink/config"
printf '\nRegistered Iceberg sink connector.\n'
