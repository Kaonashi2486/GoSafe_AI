import json

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

def filter_news_by_cities(news_data, cities):
    """Filters news based on the given list of cities and returns matching articles."""
    filtered_news = [article for article in news_data if article["city"] in cities]
    
    if not filtered_news:
        print(f"No relevant news articles found for the specified cities: {', '.join(cities)}.")
        return []
    
    return filtered_news

def save_news_to_python_file(filtered_news, output_file):
    """Saves filtered news to a Python file as a dictionary."""
    try:
        with open(output_file, "w", encoding="utf-8") as file:
            file.write("# Filtered news articles\n")
            file.write("filtered_news = ")
            json.dump(filtered_news, file, indent=4, ensure_ascii=False)
        print(f"\nFiltered news has been saved to '{output_file}'.")
    except Exception as e:
        print(f"Error writing to file: {e}")

if __name__ == "__main__":
    news_file = "news.json"  # Path to the JSON file
    output_file = "filtered_news.py"  # Output file as a Python script
    
    news_data = load_news_from_json(news_file)
    
    if news_data:
        cities = input("Enter city names (comma-separated) to fetch news: ").split(",")
        cities = [city.strip() for city in cities]  # Clean up spaces
        selected_news = filter_news_by_cities(news_data, cities)
        
        if selected_news:
            print("\nRelevant News Articles:")
            for i, article in enumerate(selected_news, 1):
                print(f"{i}. {article['city']} - {article['title']}")
                print(f"   {article['description']}")
                print(f"   Read more: {article['url']}\n")

            # Save output to a Python file
            save_news_to_python_file(selected_news, "live_historical_news.py")
