NAME=kafka-mongodb-bigquery
.PHONY: up
up:
	docker-compose up

.PHONY: curl_plugins
curl_plugins:
	curl localhost:8083/connector-plugins | json_pp
	@echo

.PHONY: curl_connectors
curl_connectors:
	curl localhost:8083/connectors | json_pp
	@echo

# CDC Configurations
.PHONY: curl_add_mongodb_cdc_connector
curl_add_mongodb_cdc_connector:
	curl -X POST -H "Content-Type: application/json" -d @config-cdc-mongodb.json http://localhost:8083/connectors | json_pp
	@echo

.PHONY: curl_remove_mongodb_cdc_connector
curl_remove_mongodb_cdc_connector:
	curl -X DELETE http://localhost:8083/connectors/config-cdc-mongodb | json_pp
	@echo

.PHONY: curl_add_mongodb_value_schema
curl_add_mongodb_value_schema:
	curl -X POST -H "Content-Type: application/json" -d @mongodb-value-schema.json http://localhost:8081/subjects/demo.mydb.colors-value/versions | json_pp
	@echo

.PHONY: create_replica_set
create_replica_set:
	docker-compose exec mongo1 /usr/bin/mongo --eval '''if (rs.status()["ok"] == 0) { \
		rsconf = { \
		_id : "rs0", \
		members: [ \
			{ _id : 0, host : "mongo1:27017", priority: 1.0 }, \
			{ _id : 1, host : "mongo2:27017", priority: 0.5 } \
		] \
		}; \
		rs.initiate(rsconf); \
	} \
	rs.conf();'''
	@echo

.PHONY: setup_cdc
setup_cdc: create_replica_set curl_add_mongodb_cdc_connector

# SINK Configurations
.PHONY: curl_add_bigquery_sink_connector
curl_add_bigquery_sink_connector:
	curl -X POST -H "Content-Type: application/json" -d @config-sink-bigquery.json http://localhost:8083/connectors | json_pp
	@echo

.PHONY: curl_remove_bigquery_sink_connector
curl_remove_bigquery_sink_connector:
	curl -X DELETE http://localhost:8083/connectors/config-sink-bigquery | json_pp
	@echo

.PHONY: setup_sink
setup_sink: curl_add_bigquery_sink_connector

.PHONY: view_topic_data
view_topic_data:
	docker-compose exec kafka kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic demo.mydb.colors --from-beginning 

.PHONY: curl_connector_status
curl_connector_status:
	curl http://localhost:8083/connectors/config-cdc-mongodb/status | json_pp
	curl http://localhost:8083/connectors/config-sink-bigquery/status | json_pp
	@echo
