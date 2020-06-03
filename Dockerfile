FROM gradle:jdk8 AS builder

RUN curl -k -SsL https://github.com/wepay/kafka-connect-bigquery/archive/master.zip -o kafka-connect-bigquery.zip \
    && unzip kafka-connect-bigquery.zip -d /tmp

RUN cd /tmp/kafka-connect-bigquery-master && ./gradlew clean distTar
RUN mkdir -p /tmp/kafka-connect-bigquery \
    && tar -xf /tmp/kafka-connect-bigquery-master/kcbq-confluent/build/distributions/kcbq-confluent-*.tar \
       -C /tmp/kafka-connect-bigquery --strip-components=1

FROM debezium/connect

ARG plugin_path=/kafka/connect
COPY --from=builder --chown=root:root /tmp/kafka-connect-bigquery ${plugin_path}/kafka-connect-bigquery
