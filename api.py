from flask import Flask, jsonify
import json
import random

app = Flask(__name__)

# Load the combined data into memory
with open('./srcs/logs_new.json', 'r') as f:
    data = json.load(f)

@app.route('/', methods=['GET'])
def get_random_json():
    random_obj = random.choice(data)
    return jsonify(random_obj)

if __name__ == '__main__':
    app.run(debug=True)
