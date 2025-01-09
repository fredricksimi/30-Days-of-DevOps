import csv
import requests
import os
from google.cloud import storage, bigquery
from dotenv import load_dotenv

# Load BigQuery and Cloud Storage Clients
storage_client = storage.Client()
bigquery_client = bigquery.Client()

#load enviroment variables
load_dotenv()
file_name = '<your-gcp-service-account-credentials.json' # Replace this with the actual filename
the_abs_path = os.path.abspath(os.path.join(os.getcwd(), os.pardir))
parent_path = os.path.abspath(os.path.join(the_abs_path, os.pardir))
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = os.path.join(parent_path, file_name) # load the service account json file to the environment

bucket_name = os.getenv('GCP_STORAGE_BUCKET_NAME')
region = os.getenv('GCP_REGION')
project_id = os.getenv('GCP_PROJECT_ID')
api_key = os.getenv('SPORTSDATA_API_KEY')
nba_endpoint = "https://api.sportsdata.io/v3/nba/scores/json/Players"

# The name for your BigQuery table
bigquery_table_name = "nba_players"

def create_gcs_bucket():
    # Create a GCS bucket
    try:
        storage_client.get_bucket(bucket_name)
        print(f"Bucket {bucket_name} exists")
    except:
        try:
            bucket = storage_client.create_bucket(
                bucket_name,
                location=region
                )
            print(f"Successfully created bucket {bucket.name}")
        except Exception as e:
            print(f"Error creating bucket: {e}")

def fetch_nba_data():
    """Fetch NBA player data from sportsdata.io."""
    try:
        headers = {"Ocp-Apim-Subscription-Key": api_key}
        response = requests.get(nba_endpoint, headers=headers)
        response.raise_for_status()  
        print("Fetched NBA data successfully.")

        # We will be storing the data in a CSV format
        fields = ['PlayerID', 'FirstName', 'LastName', 'Team', 'Position']
        out_file = "./players.csv"
        rows = []
        for player in response.json():
            the_dict = {"PlayerID": player['PlayerID'], 
                "FirstName": player["FirstName"],"LastName": player["LastName"], 
                "Team": player["Team"],"Position": player["Position"]
            }
            rows.append(the_dict.values())

        # Write the data to a CSV file
        with open(out_file, 'w', newline='', encoding='utf-8') as csvfile:
            csvwriter = csv.writer(csvfile)
            csvwriter.writerow(fields)
            csvwriter.writerows(rows) 
    except Exception as e:
        print(f"Error fetching NBA data: {e}")
        return []

def upload_data_to_gcs():
    """Upload NBA data to the GCS bucket."""
    try:
        # Upload the CSV data to GCS
        file_name = "raw-data/nba_player_data.csv"
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        blob.upload_from_filename(os.path.join(os.getcwd(), "players.csv"))
        print(f"Uploaded data to GCS: {file_name}")
    except Exception as e:
        print(f"Error uploading data to GCS: {e}")

def create_bigquery_table():
    try:
        # Create a BigQuery dataset
        dataset_name = bigquery.Dataset(f'{project_id}.my_nba_dataset')
        dataset = bigquery_client.create_dataset(dataset_name)

        # Define the BigQuery Schema
        schema = {
            bigquery.SchemaField("PlayerID", "INTEGER"),
            bigquery.SchemaField("FirstName", "STRING"),
            bigquery.SchemaField("LastName", "STRING"),
            bigquery.SchemaField("Team", "STRING"),
            bigquery.SchemaField("Position", "STRING"),
        }

        # Create the BigQuery table in the dataset
        table_ref = dataset.table(bigquery_table_name)
        table = bigquery.Table(table_ref, schema=schema)
        bigquery_client.create_table(table, exists_ok=True)

        print(f"BigQuery dataset {dataset_name} created successfully.")
    except Exception as e:
        print(f"Error creating BigQuery dataset: {e}")

def load_data_to_bigquery():
    """Load data from GCS to BigQuery."""
    bigquery_dataset_name = f'{project_id}.my_nba_dataset'
    try:
        uri = f"gs://{bucket_name}/raw-data/nba_player_data.csv"
        table_ref = f"{bigquery_dataset_name}.{bigquery_table_name}"

        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.CSV,
            autodetect=True,
        )
        load_job = bigquery_client.load_table_from_uri(
            uri, table_ref, job_config=job_config
        )
        load_job.result()  # Wait for the job to complete
        print(f"Data loaded to BigQuery table '{bigquery_table_name}'.")
    except Exception as e:
        print(f"Error loading data to BigQuery: {e}")

def main():
    print("Setting up data lake for NBA sports analytics...")
    create_gcs_bucket()
    nba_data = fetch_nba_data()
    upload_data_to_gcs()
    create_bigquery_table()
    load_data_to_bigquery()
    print("Data lake setup complete.")

if __name__ == "__main__":
    main()