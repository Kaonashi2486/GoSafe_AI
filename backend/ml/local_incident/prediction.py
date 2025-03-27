from dotenv import load_dotenv
import os
import google.generativeai as genai
from PIL import Image
import mimetypes
from io import BytesIO

# Load all the environment variables
load_dotenv()

IPFS_GATEWAY = "https://gateway.pinata.cloud/ipfs/"
# Configure Google Generative AI
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Function to load Google Gemini Pro Vision API and get response
def get_gemini_response(input_text, image_parts, prompt):
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content([input_text, image_parts[0], prompt])
    return response.text

def input_image_setup(image_path):
    # Open the image file in binary mode and read the bytes
    try:
        with open(image_path, "rb") as f:
            bytes_data = f.read()
    except Exception as e:
        raise FileNotFoundError("No file found at the provided path.") from e

    # Determine the MIME type based on the file extension
    mime_type, _ = mimetypes.guess_type(image_path)
    if mime_type is None:
        raise ValueError("Could not determine the MIME type of the image.")

    image_parts = [
        {
            "mime_type": mime_type,  # MIME type of the image
            "data": bytes_data
        }
    ]
    return image_parts

def main(image,descriptionn):
    # Get input prompt from the user
    user_input =descriptionn
    ipfsurl=f"{IPFS_GATEWAY}{image}"
    # Try to open the image using PIL
    try:
        image = ipfsurl
        print("Image loaded successfully.")
    except Exception as e:
        print("Error loading image:", e)
        return

    # Define the input prompt for the Gemini model
    input_prompt = """
You are a professional accident assessment agent. Your task is to:

1. Analyze the provided image along with the user’s description.
2. Verify if the content of the image matches the description given by the user.
   - If the image does not match the description, assign a negative score.
3. If the image matches the description, assess the severity of the accident depicted in the image on a scale of 0, 1, or 2:
   - 0: No accident or negligible impact.
   - 1: Minor accident with limited damage.
   - 2: Major accident with significant damage.
4. For scores of 0, 1, or 2, generate a concise summary that integrates both the image analysis and the user’s description. In your summary, prioritize the details from the user’s description while merging in any additional insights from the image.

Provide your output as follows:
- A score (negative if the image and description do not match, or 0/1/2 if they do).
- A brief summary (only if the score is 0, 1, or 2).

Ensure your response is clear, concise, and uses the user’s description as the primary reference point.

"""

    # Prepare image data and get the response from Gemini
    try:
        response = get_gemini_response(input_prompt, image, user_input)
        return response

        # print("\nThe Response is:")
        # print(response)
    except Exception as e:
        print("An error occurred:", e)

if __name__ == "__main__":
    main()
