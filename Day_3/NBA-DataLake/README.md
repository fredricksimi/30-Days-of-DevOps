## Ingesting NBA Player Data into BigQuery using Python, Cloud Storage, and the Sportsdata.io API
This Python script fetches player data from SportsData API saves it to Google Cloud Storage (GCS) bucket and loads it into a BigQuery table.

### Prerequisites
- Python 3.x
- Google Cloud Project with a Service Account having `Storage Admin` and `BigQuery User` privileges 
- SportsData account and its NBA API Key 
- `dotenv` library ([installation](https://pypi.org/project/python-dotenv/))

### Setting Up
1. [Create a Google Cloud project](https://console.cloud.google.com) and enable the Google Cloud Storage API if not already enabled.
2. [Create a Service Account](https://cloud.google.com/iam/docs/service-accounts-create) with Storage Admin and BigQuery User privileges and download the JSON key file 
3. Obtain an NBA API key from SportsData API Sign Up form ([Sign up](https://sportsdata.io/cart/free-trial)).
4. Create a `.env` file in the same directory as your script with the following environment variables:

```
GCP_STORAGE_BUCKET_NAME = <your_bucket_name>

GCP_REGION = <the_gcp_region_for_this_task>

SPORTSDATA_API_KEY = <api_key_here>

GCP_PROJECT_ID = <your_gcp_project_id>
```

### Code Explanation
The script handles interacting with SportsData API, Google Cloud Storage and BigQuery.
- `create_gcs_bucket()`: This method checks if the GCS bucket specified in the environment variable GCP_STORAGE_BUCKET_NAME exists. If not, it creates the bucket in the GCP_REGION.
- `fetch_nba_data()`: This method fetches nba player data from SportsData API using the `requests` library. It returns a JSON dictionary containing the players data or `None` if there is an error. The JSON data is then converted and stored as a CSV in a file
- `upload_data_to_gcs()`: This method saves the player data (in CSV format) to the GCS bucket.
- `create_bigquery_table()`: This method creates a BigQuery dataset and table
- `load_data_to_bigquery()`: This method gets the CSV data from the GCS bucket and loads it into the BigQuery table that has been created

The `main` function calls the methods to fetch and save player data to a GCS bucket, and calls the method to load the data to a BigQuery table.

### Running the Script
1. Install the required libraries:

```
pip install -r requirements.txt
```

2. Make sure you have the environment variables and values correctly in the .env file
2. Run the script:

```
python gcp_nba_datalake.py
```

**Remember to keep your API key and other credentials secure and not share it publicly.**