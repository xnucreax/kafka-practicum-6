#!/bin/bash
set -e

BOOTSTRAP="kafka-1:9092,kafka-2:9092,kafka-3:9092"
CMD_CONFIG="/etc/kafka/client.properties"

kafka-topics --create --if-not-exists \
  --topic messages \
  --partitions 3 \
  --replication-factor 2 \
  --bootstrap-server "$BOOTSTRAP" \
  --command-config "$CMD_CONFIG"

kafka-topics --create --if-not-exists \
  --topic topic-1 \
  --partitions 3 \
  --replication-factor 2 \
  --bootstrap-server "$BOOTSTRAP" \
  --command-config "$CMD_CONFIG"

kafka-topics --create --if-not-exists \
  --topic topic-2 \
  --partitions 3 \
  --replication-factor 2 \
  --bootstrap-server "$BOOTSTRAP" \
  --command-config "$CMD_CONFIG"

# topic-1: продюсеры и консьюмеры
kafka-acls --bootstrap-server "$BOOTSTRAP" --command-config "$CMD_CONFIG" \
  --add --allow-principal "User:*" \
  --operation Write --topic topic-1

kafka-acls --bootstrap-server "$BOOTSTRAP" --command-config "$CMD_CONFIG" \
  --add --allow-principal "User:*" \
  --operation Read --topic topic-1

kafka-acls --bootstrap-server "$BOOTSTRAP" --command-config "$CMD_CONFIG" \
  --add --allow-principal "User:*" \
  --operation Read --group "*"

# topic-2: только продюсеры (Read намеренно не добавляется)
kafka-acls --bootstrap-server "$BOOTSTRAP" --command-config "$CMD_CONFIG" \
  --add --allow-principal "User:*" \
  --operation Write --topic topic-2
