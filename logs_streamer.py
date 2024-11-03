import requests
from kafka import KafkaProducer
import json
import time

MOCKAROO_API_URL = "http://127.0.0.1:5000/"
KAFKA_TOPIC = "ecommerce_logs"
KAFKA_SERVER = "localhost:9092"

producer = KafkaProducer(
    bootstrap_servers=KAFKA_SERVER,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

while True:
    response = requests.get(MOCKAROO_API_URL)
    if response.status_code == 200:
        log_data = response.json()
        producer.send(KAFKA_TOPIC, log_data)
        #print(f"Sent log to Kafka: {log_data}")
    else:
        print(f"Failed to get data from API server: {response.status_code}")
    time.sleep(3)  # Adjust interval as needed
