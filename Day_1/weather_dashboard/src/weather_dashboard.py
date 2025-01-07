import os
import json
import requests
from google.cloud import storage
from google.oauth2 import service_account
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
file_name = 'MyCredentials.json'
the_abs_path = os.path.abspath(os.path.join(os.getcwd(), os.pardir))
parent_path = os.path.abspath(os.path.join(the_abs_path, os.pardir))
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = os.path.join(parent_path, file_name)

class WeatherDashboard:
    def __init__(self):
        self.api_key = os.getenv('OPENWEATHER_API_KEY')
        self.bucket_name = os.getenv('GCP_STORAGE_BUCKET_NAME')
        self.storage_client = storage.Client()

    def create_bucket_if_not_exists(self):
        # """Create GCS bucket if it doesn't exist"""
        try:
            self.storage_client.get_bucket(self.bucket_name)
            print(f"Bucket {self.bucket_name} exists")
        except:
            try:
                bucket = self.storage_client.create_bucket(
                    self.bucket_name,
                    location='us-east1'
                    )
                print(f"Successfully created bucket {bucket.name}")
            except Exception as e:
                print(f"Error creating bucket: {e}")

    def fetch_weather(self, city):
        """Fetch weather data from OpenWeather API"""
        base_url = "http://api.openweathermap.org/data/2.5/weather"
        params = {
            "q": city,
            "appid": self.api_key,
            "units": "imperial"
        }
        
        try:
            response = requests.get(base_url, params=params)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching weather data: {e}")
            return None

    def save_to_gcs_bucket(self, weather_data, city):
        """Save weather data to GCS bucket"""
        if not weather_data:
            return False
            
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        file_name = f"weather-data/{city}-{timestamp}.json"
        
        bucket = self.storage_client.bucket(self.bucket_name)
        blob = bucket.blob(file_name)
        blob.upload_from_string(json.dumps(weather_data), content_type='application/json')

        print(f"Successfully saved data for {city} to GCS Bucket")

def main():
    dashboard = WeatherDashboard()
    
    # Create bucket if needed
    dashboard.create_bucket_if_not_exists()
    
    cities = ["Cairo"]
    
    for city in cities:
        print(f"\nFetching weather for {city}...")
        weather_data = dashboard.fetch_weather(city)
        if weather_data:
            temp = weather_data['main']['temp']
            feels_like = weather_data['main']['feels_like']
            humidity = weather_data['main']['humidity']
            description = weather_data['weather'][0]['description']
            
            print(f"Temperature: {temp}°F")
            print(f"Feels like: {feels_like}°F")
            print(f"Humidity: {humidity}%")
            print(f"Conditions: {description}")
            
            # Save to GCS
            success = dashboard.save_to_gcs_bucket(weather_data, city)
            if success:
                print(f"Weather data for {city} saved to GCS!")
        else:
            print(f"Failed to fetch weather data for {city}")

if __name__ == "__main__":
    main()