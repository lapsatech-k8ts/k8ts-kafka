#!/usr/bin/env bash

KAFKA_HEAP_OPTS="-Xmx50M" \
   kafka-broker-api-versions.sh --bootstrap-server=$(hostname -f):${NODE_INT_PORT}
