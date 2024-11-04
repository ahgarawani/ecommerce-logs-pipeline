# E-commerce Logs Pipeline

This repository contains a pipeline for streaming, processing, and storing e-commerce logs. The pipeline consists of several components including a Flask API server, a Kafka producer, a Flume agent, a PySpark processor, and scripts for starting and stopping the pipeline. The processed data is stored in an InfluxDB database hosted on InfluxDB Cloud and is integrated with Grafana for visualization.

## Table of Contents
1. [Project Architecture](#project-architecture)
2. [Components](#components)
    - [Flask API Server (`api.py`)](#1-flask-api-server-apipy)
    - [Kafka Producer (`logs_streamer.py`)](#2-kafka-producer-logs_streamerpy)
    - [Flume Agent](#3-flume-agent)
    - [Processor to Database (`processor_to_db.py`)](#4-processor-to-database-processor_to_dbpy)
    - [InfluxDB](#5influxdb)
    - [Grafana](#6grafana)
    - [Scripts](#7-scripts)
        - [`start-pipeline.sh`](#start-pipelinesh)
        - [`stop-pipeline.sh`](#stop-pipelinesh)
    
3. [Dependencies](#dependencies)
4. [Getting Started](#getting-started)
    - [Cloning the Repository](#1-cloning-the-repository)
    - [Starting the Pipeline](#2-starting-the-pipeline)
    - [Stopping the Pipeline](#3-stopping-the-pipeline)
5. [Contributors](#contributors)

## Project Architecture
![Project Architecture](https://github.com/ahgarawani/ecommerce-logs-pipeline/blob/main/srcs/Architecutre.gif)

## Components

### 1. Flask API Server (`api.py`)
The Flask API server simulates an API endpoint that provides e-commerce log data. From a predefined list of mock log data, the API server returns a random log entry each time it is called.

### 2. Kafka Producer (`logs_streamer.py`)
The `logs_streamer.py` script fetches log data from the Flask API server and sends it to a Kafka topic named `ecommerce_logs`. The script runs in an infinite loop, fetching data every 3 seconds.

### 3. Flume Agent
The Flume agent is configured to read data from the Kafka topic `ecommerce_logs` and write it to HDFS. The configuration for the Flume agent is provided in the `kafka_to_hdfs.conf` file.

### 4. Processor to Database (`processor_to_db.py`)
This script processes the data and stores it in an InfluxDB database hosted on InfluxDB Cloud. It is started and stopped using the `start-pipeline.sh` and `stop-pipeline.sh` scripts respectively.

### 5.InfluxDB
InfluxDB is a time-series database that stores the processed e-commerce logs data. The data is stored in a bucket on InfluxDB Cloud.

To set up InfluxDB Cloud:
1. Sign up for an InfluxDB Cloud account at [InfluxDB Cloud](https://cloud2.influxdata.com/) (make note of the organization name).
2. Create a new bucket for storing the e-commerce logs.
3. Obtain your InfluxDB API token, organization ID, and bucket name.
4. Follow the `start-pipeline.sh` script usage to use your InfluxDB credentials.

### 6. Grafana
Graphana is a visualization tool that is integrated with InfluxDB to visualize the e-commerce logs data.

To set up Grafana:
1. Sign up for a Grafana Cloud account at [Grafana Cloud](https://grafana.com/products/cloud/).
2. Create a new data source and select InfluxDB as the type.
3. Enter your InfluxDB Cloud URL, organization ID, bucket name, and API token.
4. Create dashboards and panels to visualize the e-commerce logs data.

### 7. Scripts
- #### `start-pipeline.sh`
    This script initializes and starts all components of the pipeline:
    1. Installs Python requirements.
    2. Starts HDFS and YARN.
    3. Starts ZooKeeper and Kafka.
    4. Checks for the existence of the Kafka topic `ecommerce_logs` and creates it if it doesn't exist.
    5. Starts the Flume agent.
    6. Starts the Flask API server.
    7. Runs the `logs_streamer.py` script.
    8. Runs the `processor_to_db.py` script.

- #### `stop-pipeline.sh`
    This script stops all components of the pipeline:
    1. Stops the `processor_to_db.py` script.
    2. Stops the `logs_streamer.py` script.
    3. Stops the Flask API server.
    4. Stops the Flume agent.
    5. Stops Kafka.
    6. Stops ZooKeeper.

## Dependencies
- Python
- Kafka
- Flume
- HDFS
- YARN
- ZooKeeper
- InfluxDB
- Grafana

Ensure all dependencies are installed and properly configured before running the pipeline.

> **WARNING:** The pipeline is designed to run on a CentOS virtual machine that has the Hadoop ecosystem pre-configured on it. It was provided by the course instructor.

## Getting Started

### 1. Cloning the Repository
To clone the repository, run:
```sh
git clone https://github.com/ahgarawani/ecommerce-logs-pipeline
```
or download the repository as a zip file.

Navigate to the repository directory using:
```sh
cd ecommerce-logs-pipeline
```
### 2. Starting the Pipeline
To start the pipeline, run:
```sh
./start-pipeline.sh "your_token" "your_org" "your_bucket"
```

### 3. Stopping the Pipeline
To stop the pipeline, run on a separate terminal:
```sh
./stop-pipeline.sh
```

## Contributors

- [Aya Hussein](https://github.com/aya-hussein1)
- [Sara Mohamed](https://github.com/SaraMohamed18) 
- [Ahmed Al-Garawani](https://github.com/ahgarawani) 
