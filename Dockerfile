FROM confluentinc/cp-kafka-connect-base:5.5.0

RUN confluent-hub install --no-prompt debezium/debezium-connector-mongodb:1.1.0 \
    && confluent-hub install --no-prompt wepay/kafka-connect-bigquery:1.1.0
