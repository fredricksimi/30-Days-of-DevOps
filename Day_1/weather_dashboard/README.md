## Weather Dashboard with Google Cloud Storage and OpenWeather API
This Python script fetches weather data from OpenWeather API for a specified city and saves it to Google Cloud Storage (GCS) bucket.

### Prerequisites
- Python 3.x
- Google Cloud Project with a Service Account having Storage Admin privileges 
- OpenWeather API account and its API Key 
- `dotenv` library ([installation](https://pypi.org/project/python-dotenv/))

### Setting Up
1. [Create a Google Cloud project](https://console.cloud.google.com) and enable the Google Cloud Storage API if not already enabled.
2. [Create a Service Account](https://cloud.google.com/iam/docs/service-accounts-create) with Storage Admin privileges and download the JSON key file 
3. [Create a Google Cloud Storage bucket](https://cloud.google.com/storage?hl=en) where the weather data will be stored.
4. Obtain an API key from OpenWeather API ([Sign up](https://openweathermap.org/)).
5. Create a `.env` file in the same directory as your script with the following environment variables:

```
OPENWEATHER_API_KEY=<your_api_key>

GCP_STORAGE_BUCKET_NAME=<your_bucket_name>
```

### Code Explanation
The script defines a WeatherDashboard class that handles interacting with OpenWeather API and Google Cloud Storage.
- `create_bucket_if_not_exists()`: This method checks if the GCS bucket specified in the environment variable GCP_STORAGE_BUCKET_NAME exists. If not, it creates the bucket in the `us-east1` location.
- `fetch_weather(self, city)`: This method takes a city name as input and fetches weather data from OpenWeather API using the `requests` library. It returns a JSON dictionary containing the weather data or `None` if there is an error.
- `save_to_gcs_bucket(self, weather_data, city)`: This method saves the weather data (in JSON format) to the GCS bucket. It creates a filename with a timestamp to ensure uniqueness.

The `main` function creates a `WeatherDashboard` object and calls the methods to fetch and save weather data for a list of cities (currently set to `["Cairo", "Nairobi", "London"]`).

### Running the Script
1. Install the required libraries:

```
pip install -r requirements.txt
```

2. Replace `<your_api_key>` and `<your_bucket_name>` in the `.env` file with your actual values.
3. Run the script:

```
python weather_dashboard.py
```

This will print the weather data for each city to the Console and save it to the specified GCS bucket.

### Additional Notes
This is a basic example and can be extended to support more functionalities like:
- Fetching weather data for multiple cities at once based on user input.
- Processing and visualizing the weather data.
- Scheduling automatic weather data updates.

**Remember to keep your API key secure and not share it publicly.**