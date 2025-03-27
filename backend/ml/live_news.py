from newsdataapi import NewsDataApiClient

# Initialize the client with your API key
api = NewsDataApiClient(apikey='pub_71121e6cd6801ed9414b52e8958d8b3278db5')  # Replace 'YOUR_API_KEY' with your actual API key

# Fetch news articles related to Maharashtra
response = api.news_api(
    q='Maharashtra',  # Query for Maharashtra
    country='in',     # Country code for India
    language='en',    # Language preference
    category='crime'  # Category filter
)

# Check if the request was successful
if response['status'] == 'success':
    articles = response.get('results', [])
    if articles:
        print(f"Found {len(articles)} articles about Maharashtra:")
        for i, article in enumerate(articles, 1):
            print(f"{i}. {article['title']}")
            print(f"   {article['description']}")
            print(f"   Read more: {article['link']}\n")
    else:
        print("No articles found for Maharashtra.")
else:
    print("Failed to fetch news articles. Please check your API key and parameters.")
