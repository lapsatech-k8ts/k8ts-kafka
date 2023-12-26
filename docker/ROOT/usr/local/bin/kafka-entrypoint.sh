#!/usr/bin/env bash

CDIR=$(cd $(dirname $0); pwd)

function die() {
   >&2 echo "$1"
   exit 1
}

function required_var() {
  test "x${!1}" == "x" && die "$1 var is required"
}

function override_args() {
  while read -r name; do
    [[ "$name" =~ \s*(OVERRIDE_(.*))\s*=.* ]] && {
        VAR="${BASH_REMATCH[1]}"
        NO_PREFIX_VAR="${BASH_REMATCH[2]}"
        KAFKA_OVERRIDE_ARG=$(echo -n "$NO_PREFIX_VAR" | tr '[:upper:]' '[:lower:]' | sed -e 's/_/./g')
        KAFKA_OVERRIDE_VALUE=${!VAR}
        echo " --override ${KAFKA_OVERRIDE_ARG}=${KAFKA_OVERRIDE_VALUE}"
    }
  done < <(env)
}

required_var ZOOKEEPER_CONNECT
required_var DATA_DIR
required_var NODE_LISTEN_PORT
required_var NODE_SVC_NAME
required_var NODE_INDEX

LOCAL_LOGS_DIR=${LOCAL_LOGS_DIR:-$(mktemp -d)}
MEMORY_HEAP=${MEMORY_HEAP:-256M}

_CMD="kafka-server-start.sh /opt/kafka/config/server.properties \
          --override broker.id=${NODE_INDEX} \
          --override zookeeper.connect=${ZOOKEEPER_CONNECT} \
          --override listeners=PLAINTEXT://:${NODE_LISTEN_PORT} \
          --override advertised.listeners=PLAINTEXT://${NODE_SVC_NAME}:${NODE_LISTEN_PORT} \
          $(override_args)"

true \
  && export _LOG_THRESHOLD=${LOG_LEVEL:-INFO} \
  && export LOG_DIR=${LOCAL_LOGS_DIR} \
  && export KAFKA_HEAP_OPTS="-Xmx${MEMORY_HEAP} -Xms${MEMORY_HEAP}" \
  && echo "LOG_DIR=${LOG_DIR}" \
  && echo "KAFKA_HEAP_OPTS=${KAFKA_HEAP_OPTS}" \
  && echo $_CMD \
  && exec $_CMD \
  && true
