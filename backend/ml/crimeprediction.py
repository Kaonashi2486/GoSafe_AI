import pandas as pd
import google.generativeai as genai


genai.configure(api_key="ur gemini key")  

prompt_template = """
You are a CSV data analysis assistant. Your task is to analyze the provided CSV data containing crime records for a specific area.
Based on the data, predict and analyze the crime trends in the specified area.

For the area provided by the user, please provide:
  - The highest occurring crime type in that area.
  - The severity rate for that crime type.

Present your output in a structured format. For example:

Area: [Area Name]
Crime Analysis:
  - Highest Occurring Crime: [Type], Severity Rate: [Value]

If the data for the area is insufficient, indicate that appropriately.

Input (area): {input_text}

Data Context:
{context}

Output:
"""

# Function to process the user input and generate analysis using Gemini
def analyze_crime_data(user_area):
    # Prepare the input for Gemini
    
  # Load CSV
  df = pd.read_csv('mumbai_crime_data_updated.csv')  # Replace with your CSV file path

  # Initialize Gemini model
  model = genai.GenerativeModel('gemini-pro')  # Use the Gemini Pro model

  # Filter the DataFrame to include only rows matching the user's area
  filtered_df = df[df['City'] == user_area]  # Assuming 'City' is the column for area names

  # Check if any rows match the user's area
  if filtered_df.empty:
    print(f"No data found for the area: {user_area}")
  else:
    # Convert the filtered data to a dictionary for context
    context = filtered_df.to_dict(orient='records')  # Convert rows to a list of dictionaries

    prompt = prompt_template.format(input_text=user_area, context=context)
    
    # Generate analysis using Gemini
    response = model.generate_content(prompt)
    
    return response.text

  # Get user input for the area
  # user_area = input("Enter the area to analyze: ")
    
  #   # Generate analysis using Gemini
  #   analysis_result = analyze_crime_data(user_area)
    
  #   # Print the analysis
  #   print(f"Analysis for Area: {user_area}")
  #   print(analysis_result)