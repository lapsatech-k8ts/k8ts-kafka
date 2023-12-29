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
required_var NODE_INDEX

LOCAL_LOGS_DIR=${LOCAL_LOGS_DIR:-$(mktemp -d)}
MEMORY_HEAP=${MEMORY_HEAP:-256M}

NODE_INT_NAME=$(hostname -f)
required_var NODE_INT_PORT

required_var NODE_EXT_NAME_PRINTF
NODE_EXT_NAME=$(printf "${NODE_EXT_NAME_PRINTF}" ${NODE_INDEX})

required_var NODE_EXT_PORT_PRINTF
NODE_EXT_PORT=$(printf "${NODE_EXT_PORT_PRINTF}" ${NODE_INDEX})

_CMD="kafka-server-start.sh /opt/kafka/config/server.properties \
          --override broker.id=${NODE_INDEX} \
          --override zookeeper.connect=${ZOOKEEPER_CONNECT} \
          --override listeners=INTERNAL://0.0.0.0:${NODE_INT_PORT},EXTERNAL://0.0.0.0:${NODE_EXT_PORT} \
          --override listener.security.protocol.map=INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT \
          --override advertised.listeners=INTERNAL://${NODE_INT_NAME}:${NODE_INT_PORT},EXTERNAL://${NODE_EXT_NAME}:${NODE_EXT_PORT} \
          --override inter.broker.listener.name=INTERNAL \
          $(override_args)"

test "${DONT_START}x" = "x" && _CMD="exec ${_CMD}" || _CMD="echo ${_CMD}"

true \
  && export _LOG_THRESHOLD=${LOG_LEVEL:-INFO} \
  && export LOG_DIR=${LOCAL_LOGS_DIR} \
  && export KAFKA_HEAP_OPTS="-Xmx${MEMORY_HEAP} -Xms${MEMORY_HEAP}" \
  && echo "LOG_DIR=${LOG_DIR}" \
  && echo "KAFKA_HEAP_OPTS=${KAFKA_HEAP_OPTS}" \
  && echo ${_CMD} \
  && ${_CMD} \
  && true

ret=$?
echo "Exit code ${ret}"

sleep 20s
exit $ret
