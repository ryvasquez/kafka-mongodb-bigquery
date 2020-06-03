# kafka-mongodb-bigquery

A Kafka CDC Mongodb to Biquery as a sink implementation

### Requirements
- To have a google service account credential in file named `credential.json`.
- Docker 19.03.8 or up
- docker-compose 1.25.5 or up
- make 3.81 or up
- available port `27017` for MongoDB container

### Usage

##### Setup applications
```
make up
```
This command will give setup the following
- zookeeper
- Kafka
- Debezium connectors
- MongoDB
- schema registry


##### Setup mongodb connector CDC
```
make setup_cdc
```

##### Setup bigquery connector sink
```
make setup_sink
```