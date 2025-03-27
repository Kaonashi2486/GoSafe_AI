from newsdataapi import NewsDataApiClient


api = NewsDataApiClient(apikey='livw nes api key')
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
