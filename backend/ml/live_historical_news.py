import os
import dotenv
from langchain.prompts import ChatPromptTemplate
from langchain_groq.chat_models import ChatGroq
from langchain.globals import set_llm_cache
from langchain.cache import InMemoryCache
set_llm_cache(InMemoryCache())
from langchain.chains import LLMChain
from crimeprediction import analyze_crime_data 

# Load environment variables and set up caching
dotenv.load_dotenv()
set_llm_cache(InMemoryCache())
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = os.getenv("LANGCHAIN_API_KEY")


os.environ["GROQ_API_KEY"] = os.getenv("GROQ_API_KEY")


prompt = ChatPromptTemplate.from_template(
    template="""You are an AI specialized in analyzing crime news.
You are provided with two sets of data:
1. **Live Crime News:** Real-time crime news of the city.
2. **Historical Crime News:** Crime news data provided by a machine learning model.

Your task is to compare the two reports. If both reports refer to the same type of crime, please:
- Generate a score on a scale of 1 to 100 reflecting the severity or frequency of the crime.also give
- Provide a concise summary that integrates both reports. For example: 
  "A recent theft occurred in this area... thefts have been frequent historically."

If the reports pertain to different crimes, indicate that the crimes differ and provide a brief comparative summary.

**Live Crime News:**
{live_news}

**Historical Crime News:**
{historical_news}

Please format your answer as follows:
Score: [score]/10 Summary: [your summary here]
"""
)

def compare_crime_news(area):
    # For live news data, derive data from a JSON file. When an area is entered, the data is fetched from the JSON file.
    # Assuming the JSON file is named 'live_news.json' and has a structure like:
    # {
    #     "area1": "Live news data for area1",
    #     "area2": "Live news data for area2",
    #     ...
    # }
    def get_live_news(area):
        import json
        try:
            with open('news.json', 'r') as file:
                data = json.load(file)
                return data.get(area, "No live news available for this area.")
        except FileNotFoundError:
            return "Live news file not found."

    # Retrieve live and historical crime news data
    live_news = get_live_news(area)
    historical_news =analyze_crime_data(area)  #get_historical_news()

    if not live_news or not historical_news:
        print("News data not available.")
        return {"message": "News data not available."}

    chat = ChatGroq(
    model="mixtral-8x7b-32768",
    temperature=0.0,
    )

    # Create an LLMChain using the prompt and the language model
    chain = LLMChain(llm=chat, prompt=prompt)
    analysis = chain.run({
        "live_news": live_news,
        "historical_news": historical_news
    })

    # Print the analysis directly
    print("Crime news analysis:")
    print(analysis)
    return {"message": "Crime news comparison completed successfully."}

if __name__ == "__main__":
    compare_crime_news()
