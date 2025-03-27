import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import OneHotEncoder, LabelEncoder
from sklearn.metrics import accuracy_score, classification_report
import joblib

# Load dataset
file_path = "mumbai_crime_data_updated.csv"  # Replace with your actual file path
df = pd.read_csv(file_path)

# Print column names to verify
print("Columns in the dataset:", df.columns)

# Handling missing values
# Avoid inplace=True and reassign columns
df['Time of Occurrence'] = df['Time of Occurrence'].fillna(df['Time of Occurrence'].mode()[0])
df['Severity'] = df['Severity'].fillna(df['Severity'].median())
df['City'] = df['City'].fillna('Unknown')

# Check if 'Victim Age' exists before processing
if 'Victim Age' in df.columns:
    df['Victim Age'] = df['Victim Age'].fillna(df['Victim Age'].median())
else:
    print("Warning: 'Victim Age' column not found in the dataset. Skipping imputation.")

# Check if 'Victim Gender' exists before processing
if 'Victim Gender' in df.columns:
    df['Victim Gender'] = df['Victim Gender'].fillna('Unknown')
else:
    print("Warning: 'Victim Gender' column not found in the dataset. Skipping imputation.")

# Check if 'Weapon Used' exists before processing
if 'Weapon Used' in df.columns:
    df['Weapon Used'] = df['Weapon Used'].fillna('Unknown')
else:
    print("Warning: 'Weapon Used' column not found in the dataset. Skipping imputation.")

# Feature Engineering
# Extract Hour from Time of Occurrence
df['Hour'] = pd.to_datetime(df['Time of Occurrence'], format='%H').dt.hour

# Extract Day of the Week from Date of Occurrence
df['Date of Occurrence'] = pd.to_datetime(df['Date of Occurrence'], format='%d-%m-%Y')
df['Day of Week'] = df['Date of Occurrence'].dt.day_name()

# One-Hot Encoding for categorical features
categorical_cols = ['City', 'Victim Gender', 'Weapon Used', 'Day of Week']
df = pd.get_dummies(df, columns=categorical_cols, drop_first=True)

# Encode Crime Description (target variable)
label_enc_crime = LabelEncoder()
df['Crime Description'] = label_enc_crime.fit_transform(df['Crime Description'])

# Features and target variable
X = df.drop(['Crime Description', 'Date Reported', 'Date of Occurrence', 'Time of Occurrence'], axis=1)
y = df['Crime Description']

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train a Random Forest Classifier with class_weight='balanced' to handle class imbalance
clf = RandomForestClassifier(random_state=42, class_weight='balanced')

# Hyperparameter Tuning using GridSearchCV
param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [None, 10, 20, 30],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4],
    'max_features': ['sqrt', 'log2']
}

grid_search = GridSearchCV(estimator=clf, param_grid=param_grid, cv=5, scoring='accuracy', n_jobs=-1)
grid_search.fit(X_train, y_train)

# Best model from GridSearchCV
best_clf = grid_search.best_estimator_
print("Best Parameters:", grid_search.best_params_)

# Predict on test data
y_pred = best_clf.predict(X_test)

# Model Evaluation
print("Accuracy:", accuracy_score(y_test, y_pred))


# Save model and encoders
joblib.dump(best_clf, "crime_severity_model.pkl")
joblib.dump(label_enc_crime, "crime_encoder.pkl")

print("Model and encoders saved successfully!")