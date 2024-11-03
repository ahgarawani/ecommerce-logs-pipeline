from datetime import datetime
from pyspark.sql import SparkSession, Row
from pyspark.sql.types import StructType, TimestampType, IntegerType, StringType
from kafka import KafkaConsumer
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import json
import os
import certifi

# Initialize Spark session
spark = SparkSession.builder \
    .appName("EcommerceLogProcessing") \
    .getOrCreate()

# Define schema for incoming data
schema = StructType() \
    .add("timestamp", TimestampType(), True) \
    .add("user_id", IntegerType(), True) \
    .add("event_type", StringType(), True) \
    .add("product_id", IntegerType(), True) \
    .add("response_time", IntegerType(), True) \
    .add("status_code", IntegerType(), True) \
    .add("device_type", StringType(), True)

# Configure InfluxDB Client
influx_token = os.getenv("INFLUXDB_API_TOKEN")
influx_org = os.getenv("INFLUXDB_ORG")
influx_bucket = os.getenv("INFLUXDB_BUCKET")
influx_url = os.getenv("INFLUXDB_URL")

client = InfluxDBClient(url=influx_url, token=influx_token, org=influx_org, ssl_ca_cert=certifi.where())
write_api = client.write_api(write_options=SYNCHRONOUS)

# Initialize Kafka Consumer
consumer = KafkaConsumer(
    'ecommerce_logs',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='latest',
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

for message in consumer:
    data = message.value
    if isinstance(data, dict):
        # Parse timestamp into a Python datetime object
        timestamp = datetime.strptime(data['timestamp'], "%m/%d/%Y")  # Adjust format as needed
        
        # Convert data to DataFrame
        rows = [Row(
            timestamp=timestamp,
            user_id=data['user_id'],
            event_type=data['event_type'],
            product_id=data['product_id'],
            response_time=data['response_time'],
            status_code=data['status_code'],
            device_type=data['device_type']
        )]
        
        df = spark.createDataFrame(rows, schema=schema)
        
        # Write each row to InfluxDB
        for row in df.collect():
            point = Point("ecommerce_event") \
                .field("user_id", row.user_id) \
                .field("event_type", row.event_type) \
                .field("product_id", row.product_id) \
                .field("response_time", row.response_time) \
                .field("status_code", row.status_code) \
                .field("device_type", row.device_type) \
                .time(row.timestamp)
            
            write_api.write(bucket=influx_bucket, org=influx_org, record=point)

    else:
        print("Unexpected data format:", data)

# Close InfluxDB client after use
client.close()

