## Deploying a Flask Web App on Cloud Run and Implementing Traffic Splitting on Google Cloud

### For Deployment to Cloud Run and Splitting Traffic, read more about it on [my article](https://fredricksimi.hashnode.dev/day-4-deploying-a-flask-web-app-on-cloud-run-and-implementing-traffic-splitting-on-google-cloud) after setting up the project locally with the steps below.

### Prerequisites
1. Python 3.x
2. [Create a Google Cloud project](https://console.cloud.google.com) with the Cloud Build Service Account role granted to the Compute Engine default service account
3. `gcloud` CLI installed locally on your computer ([Instructions](https://cloud.google.com/sdk/docs/install))


### Setting up the project locally
Clone this repo and navigate to Day_4 folder
```
$ git clone https://github.com/fredricksimi/30-Days-of-DevOps.git

$ cd 30-Days-of-DevOps/Day_4
```

Create & activate a virtual environment and install the dependencies
```
# Create the virtual environment
$ python -m venv venv


# Activate the virtual environment
$ venv\Scripts\activate # For Windows

$ source venv/bin/activate # For MacOS/Linux


# Install the dependencies
$ pip install -r requirements.txt
```

Run the project and visit `http://127.0.0.1:8080`
```
(venv)$ python main.py
```
