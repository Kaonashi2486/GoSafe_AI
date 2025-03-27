from flask import Flask, request, jsonify

app = Flask(__name__)
from crimeprediction import analyze_crime_data 
from live_historical_news import compare_crime_news
from local_incident.prediction import main
import json
import requests


NODE_JS_SERVER = "https://2742-123-252-147-173.ngrok-free.app"  # Change if Node.js runs on a different port

#import new jsn file
def load_news_from_json(file_path):
    """Loads news data from a JSON file."""
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return json.load(file).get("news", [])
    except FileNotFoundError:
        print("Error: The news file was not found.")
        return []
    except json.JSONDecodeError:
        print("Error: The JSON file is not formatted correctly.")
        return []
# Sample data storage (acts as a database for now)
data_store = []


#call the function imported above with post request
#take parameters from the user

@app.route('/crimeprediction', methods=['POST'])
def crimeprediction():
    data = request.json
    area = data.get('area')
    print(area)
    if not area :
        return jsonify({'error': 'Missing area or context'}), 400
    return analyze_crime_data(area)

@app.route('/live_historical_news', methods=['POST'])
def live_historical_news():
    data = request.json
    area = data.get('area')
    return compare_crime_news(area)


@app.route('/fetch_incident/<int:incident_id>', methods=['GET'])
def fetch_incident(incident_id):
    try:
        # ✅ Fetch data from Node.js API
        node_api_url = f"{NODE_JS_SERVER}/incident/{incident_id}"
        response = requests.get(node_api_url)

        if response.status_code == 200:
            incident_data = response.json()

            # ✅ Process data (Example: Print & return it)
            print(f"Received from Node.js: {incident_data}")
            return jsonify({"message": "Incident data processed", "data": incident_data})

        else:
            return jsonify({"error": "Incident not found"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/local_incident_prediction', methods=['POST'])
def process_photo():
    data = request.get_json()
    photo_hash = data.get("photoHash", "")

    print(f"Processing Photo from IPFS: {photo_hash}")
    return jsonify({"message": "Photo processed successfully", "photoHash": photo_hash})

    return main()



# POST request: Add new data
@app.route('/data', methods=['POST'])
def post_data():
    data = request.json  # Get JSON data from the request body
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    data_store.append(data)  # Store data
    return jsonify({'message': 'Data added successfully!', 'data': data}), 201

if __name__ == '__main__':
    app.run(debug=True)
