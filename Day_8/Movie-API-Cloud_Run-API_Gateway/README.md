## Day 8 - Deploying a Python Movie API to Google Cloud Run using Bash Scripting, Docker, Artifact Registry and API Gateway

### For Deployment process, read more about it on [my article](https://fredricksimi.hashnode.dev/day-7-deploying-a-python-application-to-app-engine-using-google-cloud-build-cicd) after setting up the project locally with the steps below.

### Prerequisites
1. Python 3.x
2. [The MovieDB (TMDB)](https://www.themoviedb.org/) API Key. Create an account, then get your API Key [here](https://www.themoviedb.org/settings/api) after logging in.
3. Google Cloud Project with the Cloud Run Admin & ApiGateway Admin roles granted to a [Service Account](https://cloud.google.com/iam/docs/service-accounts-create).
4. The Service Account email
5. gcloud CLI installed locally on your computer ([Instructions](https://cloud.google.com/iam/docs/service-accounts-create))
6. Docker ([Instructions](https://cloud.google.com/iam/docs/service-accounts-create))


### Setting up the project locally
Clone this repo and navigate to Day_4 folder
```
$ git clone https://github.com/fredricksimi/30-Days-of-DevOps.git

$ cd 30-Days-of-DevOps/Day_8
```

Create & activate a virtual environment and install the dependencies
```
# Create the virtual environment
$ python -m venv venv


# Activate the virtual environment
$ source venv/bin/activate # For MacOS/Linux


# Install the dependencies
$ pip install -r requirements.txt
```

Run the project and visit `http://127.0.0.1:8080`
```
(venv)$ python app.py
```