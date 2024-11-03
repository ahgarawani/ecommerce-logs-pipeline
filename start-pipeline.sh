#!/bin/bash

# Install Python requirements
echo "Installing Python requirements..."
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt not found. Skipping Python requirements installation."
fi

# Start HDFS in the background
echo "Starting HDFS..."
start-dfs.sh &
HDFS_PID=$!
wait $HDFS_PID
if [ $? -ne 0 ]; then
    echo "Failed to start HDFS. Exiting."
    exit 1
fi

# Start YARN in the background
echo "Starting YARN..."
start-yarn.sh &
YARN_PID=$!
wait $YARN_PID
if [ $? -ne 0 ]; then
    echo "Failed to start YARN. Exiting."
    exit 1
fi

# Start ZooKeeper in the background
echo "Starting ZooKeeper..."
$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties &
ZOOKEEPER_PID=$!
sleep 5  # Allow ZooKeeper some time to initialize

# Start Kafka in the background
echo "Starting Kafka..."
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
KAFKA_PID=$!
sleep 5  # Allow Kafka some time to initialize

# Check if the Kafka topic exists, create it if it doesn't
echo "Checking for existing Kafka topic 'ecommerce_logs'..."
TOPIC_EXISTS=$($KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 | grep -w "ecommerce_logs")

if [ -z "$TOPIC_EXISTS" ]; then
    echo "Creating Kafka topic 'ecommerce_logs'..."
    $KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic ecommerce_logs
    if [ $? -ne 0 ]; then
        echo "Failed to create Kafka topic. Exiting."
        exit 1
    fi
else
    echo "Kafka topic 'ecommerce_logs' already exists. Skipping creation."
fi

# Start Flume agent in the background
echo "Starting Flume agent..."
$FLUME_HOME/bin/flume-ng agent --conf conf --conf-file ./kafka_to_hdfs.conf --name agent -Dflume.root.logger=DEBUG,console &
FLUME_PID=$!
sleep 5

# Start the Flask server (api.py) in the background
echo "Starting Flask server (api.py)..."
python api.py &
FLASK_PID=$!
sleep 2  # Give Flask server time to initialize

# Run logs_streamer.py in the background
echo "Running logs_streamer.py..."
python logs_streamer.py &
STREAMER_PID=$!

# Set default values for InfluxDB variables
DEFAULT_INFLUXDB_API_TOKEN="zLOQpwCq2Nw7vUhmuUBeUrcDrGFMwSpQCLrbbHmZ4o3wmqufvoixv_KIKU-4yFh5vLUHCKUpyPog15rZiBv3EQ=="
DEFAULT_INFLUXDB_ORG="NTI"
DEFAULT_INFLUXDB_BUCKET="ecommerce"
DEFAULT_INFLUXDB_URL="https://us-east-1-1.aws.cloud2.influxdata.com"

# Set InfluxDB environment variables based on arguments or default values
INFLUXDB_API_TOKEN=${1:-$DEFAULT_INFLUXDB_API_TOKEN}
INFLUXDB_ORG=${2:-$DEFAULT_INFLUXDB_ORG}
INFLUXDB_BUCKET=${3:-$DEFAULT_INFLUXDB_BUCKET}
INFLUXDB_URL=${4:-$DEFAULT_INFLUXDB_URL}

export INFLUXDB_API_TOKEN
export INFLUXDB_ORG
export INFLUXDB_BUCKET
export INFLUXDB_URL

echo "Using InfluxDB API Token: $INFLUXDB_API_TOKEN"
echo "Using InfluxDB Organization: $INFLUXDB_ORG"
echo "Using InfluxDB Bucket: $INFLUXDB_BUCKET"
echo "Using InfluxDB URL: $INFLUXDB_URL"

# Run processor_to_db.py in the background
echo "Running processor_to_db.py..."
python processor_to_db.py &
PROCESSOR_PID=$!

# Wait for all background processes to complete
wait $FLASK_PID $STREAMER_PID $PROCESSOR_PID

echo "All services and scripts have been started successfully."

