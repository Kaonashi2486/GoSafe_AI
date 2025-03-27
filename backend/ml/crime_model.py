import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.cluster import KMeans

# Load the dataset
df = pd.read_csv("./mumbai_crime_data_updated.csv")

# Encode 'City' as numerical values
label_encoder = LabelEncoder()
df['City_Encoded'] = label_encoder.fit_transform(df['City'])

# Select features for clustering
features = df[['City_Encoded', 'Time of Occurrence']]

# Apply K-Means clustering
k = 4  # Number of clusters (can be adjusted)
kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
df['Cluster'] = kmeans.fit_predict(features)

# Analyze the clusters
cluster_analysis = df.groupby("Cluster")['Severity'].mean().sort_values()

# Map clusters to severity levels
severity_mapping = {cluster: idx + 1 for idx, cluster in enumerate(cluster_analysis.index)}
df['Predicted_Severity'] = df['Cluster'].map(severity_mapping)

# Save the model and label encoder for future use
import pickle
with open("kmeans_model.pkl", "wb") as f:
    pickle.dump(kmeans, f)
with open("label_encoder.pkl", "wb") as f:
    pickle.dump(label_encoder, f)

# Display sample results
print(df[['City', 'Time of Occurrence', 'Severity', 'Predicted_Severity']].head())
