import pandas as pd
import google.generativeai as genai

# Set up Gemini API
genai.configure(api_key="AIzaSyA0bOUlMhYmkow2EvVMyV-mGfpLtZeHGoE")  # Replace with your Gemini API key

# Load CSV
df = pd.read_csv('mumbai_crime_data_updated.csv')  # Replace with your CSV file path

# Initialize Gemini model
model = genai.GenerativeModel('gemini-pro')  # Use the Gemini Pro model

# Define the prompt template
prompt_template = """
give the location of:{lat},{long}
"""

# Function to process the user input and generate analysis using Gemini
def analyze_crime_data():
    try:
        lat = input("Enter the latitude: ")
        long = input("Enter the longitude: ")
        # Prepare the input for Gemini
        prompt = prompt_template.format(lat=lat, long=long)
        
        # Generate analysis using Gemini
        response = model.generate_content(prompt)
        print(response.text)
        return response.text
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

# Call the function to execute the code
analyze_crime_data()