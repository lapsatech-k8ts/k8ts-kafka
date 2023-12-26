FROM ubuntu:16.04 

RUN set -x \
    && apt-get update \
    && apt-get install -y openjdk-8-jre-headless \
                          netcat \
    && rm -rf /var/lib/apt/lists/* \
    && true

ENV PATH=/opt/kafka/bin:${PATH} \
    KAFKA_VERSION=3.6.1 \
    KAFKA_HOME=/opt/kafka

RUN set -x \
    && DIST_NAME=kafka_2.13-${KAFKA_VERSION} \
    \
    && apt-get update \
    && apt-get install -y curl \
    && curl -f -o DIST.tar.gz \
            "https://downloads.apache.org/kafka/${KAFKA_VERSION}/${DIST_NAME}.tgz" \
    && tar -xzf DIST.tar.gz -C /opt \
    && rm -rfv DIST.tar.gz \
    && mv -vT /opt/$DIST_NAME /opt/kafka \
    && chmod -v +x /opt/kafka/bin/* \
    && mkdir -vp /opt/kafka/logs \
    && apt-get autoremove -y curl \
    && rm -rf /var/lib/apt/lists/* \
    \
    && which kafka-server-start.sh \
    && true

RUN set -x \
    && apt-get update \
    && apt-get install -y vim \
    && true

COPY ROOT /

RUN set -x \
    && chmod -v +x /usr/local/bin/* \
    && which kafka-entrypoint.sh \
    && which kafka-ready.sh \
    && true

ENTRYPOINT kafka-entrypoint.sh

#    \
#    && which zkCli.sh \
#    && which zkServer.sh \
#KAFKA_DATA_DIR=/var/lib/kafka/data \
#    && mkdir -p $KAFKA_DATA_DIR \
#ARG KAFKA_DIST=kafka_2.11-0.10.2.1
#RUN set -x \
#COPY log4j.properties /opt/$KAFKA_DIST/config/
