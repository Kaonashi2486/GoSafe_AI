import pandas as pd
import pickle
from sklearn.preprocessing import LabelEncoder

# Load the trained model and label encoder
with open("kmeans_model.pkl", "rb") as f:
    kmeans = pickle.load(f)
with open("label_encoder.pkl", "rb") as f:
    label_encoder = pickle.load(f)

# Function to predict crime severity
def predict_severity(city, time_of_occurrence):
    city_encoded = label_encoder.transform([city])[0]  # Encode the input city
    features = [[city_encoded, time_of_occurrence]]
    cluster = kmeans.predict(features)[0]  # Predict cluster
    
    # Mapping clusters to severity levels (should match training mapping)
    severity_mapping = {cluster: idx + 1 for idx, cluster in enumerate(sorted(set(kmeans.labels_)))}
    predicted_severity = severity_mapping.get(cluster, "Unknown")
    
    return predicted_severity

# Example usage
city = "Andheri East"
time_of_occurrence = 1  # 2 PM
severity = predict_severity(city, time_of_occurrence)

print(f"Predicted severity of crime in {city} at {time_of_occurrence}:00 is {severity}")
