## Deploying a Web App on Google Kubernetes Engine (GKE) using Terraform & Docker

### For the deployment process, read about it on [my article](https://fredricksimi.hashnode.dev/day-6-deploying-a-web-app-on-google-kubernetes-engine-gke-using-terraform-docker) after setting up the project locally with the steps below.

### Prerequisites
1. Python 3.x

2. Google Cloud Project with the `Compute Admin`, `Compute Network Admin`, `Kubernetes Engine Admin` & `Service Account User` roles granted to a **Service account**.

3. The Service Account Key JSON file downloaded locally.

4. `gcloud CLI` installed locally on your computer ([Instructions](https://cloud.google.com/sdk/docs/install))

5. Terraform ([Instructions](https://developer.hashicorp.com/terraform/downloads))

6. Docker ([Instructions](https://www.docker.com/))


### Setting up the project locally
Clone this repo and navigate to Day_4 folder
```
$ git clone https://github.com/fredricksimi/30-Days-of-DevOps.git

$ cd 30-Days-of-DevOps/Day_6
```

Proceed by following the next steps on the article ☝️