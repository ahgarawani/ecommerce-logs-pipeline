#!/bin/bash

# Stop processor_to_db.py
echo "Stopping processor_to_db.py..."
PROCESSOR_PID=$(ps aux | grep "python processor_to_db.py" | grep -v grep | awk '{print $2}')
if [ -n "$PROCESSOR_PID" ]; then
    kill -SIGTERM $PROCESSOR_PID
    echo "processor_to_db.py stopped."
else
    echo "processor_to_db.py is not running."
fi

# Stop logs_streamer.py
echo "Stopping logs_streamer.py..."
STREAMER_PID=$(ps aux | grep "python logs_streamer.py" | grep -v grep | awk '{print $2}')
if [ -n "$STREAMER_PID" ]; then
    kill -SIGTERM $STREAMER_PID
    echo "logs_streamer.py stopped."
else
    echo "logs_streamer.py is not running."
fi

# Stop Flask server (api.py)
echo "Stopping Flask server..."
FLASK_PID=$(ps aux | grep "python api.py" | grep -v grep | awk '{print $2}')
if [ -n "$FLASK_PID" ]; then
    kill -SIGTERM $FLASK_PID
    echo "Flask server stopped."
else
    echo "Flask server is not running."
fi

# Stop Flume agent
echo "Stopping Flume agent..."
FLUME_PID=$(ps aux | grep "flume" | grep -v grep | awk '{print $2}')
if [ -n "$FLUME_PID" ]; then
    kill -SIGTERM $FLUME_PID
    echo "Flume agent stopped."
else
    echo "Flume agent is not running."
fi

# Stop Kafka
echo "Stopping Kafka..."
$KAFKA_HOME/bin/kafka-server-stop.sh

# Stop ZooKeeper
echo "Stopping ZooKeeper..."
$KAFKA_HOME/bin/zookeeper-server-stop.sh

echo "All services and scripts have been stopped."

