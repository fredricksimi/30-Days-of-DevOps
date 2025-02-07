#!/bin/bash

export PROJECT_ID="<GCP-PROJECT-ID-HERE>" # Replace with your GCP project ID
export REGION="<GCP-REGION-HERE>"        # GCP region i.e us-east1

export LOCAL_CONTAINER_IMAGE="<IMAGE-NAME-HERE>" # The name you gave for your container image
export ARTIFACT_REGISTRY_REPO="<REPO-NAME-HERE>" # The name you gave for your artifact registry repository

export CLOUD_RUN_SERVICE_NAME="<CLOUD-RUN-SERVICE-NAME-HERE>" # The name you gave for your Cloud Run service
export API_NAME="<API-NAME-HERE>" # The name you gave for your API

####################### THE FOLLOWING TWO ENTRIES ARE NEW ###############################
export API_GATEWAY="movie-api-gateway-instance" ##  NEW - You'll find this name in the deploy_outputs.txt file generated
export API_GATEWAY_CONFIG="movie-api-gateway-config"  #  NEW - You'll find this name in the deploy_outputs.txt file generated
#################### NO NEED TO MODIFY ANY LINES BELOW THIS ONE #########################


# Delete API Gateway
gcloud api-gateway gateways delete movie-api-gateway-instance --location=$REGION --quiet

# Delete API Config
gcloud api-gateway api-configs delete $API_GATEWAY_CONFIG --api=$API_NAME --project=$PROJECT_ID --quiet

# Delete the API
gcloud api-gateway apis delete $API_NAME --project=$PROJECT_ID --quiet

# Delete Cloud Run Service
gcloud run services delete $CLOUD_RUN_SERVICE_NAME --region=$REGION --quiet

# Delete Artifact Registry repo
gcloud artifacts repositories delete $ARTIFACT_REGISTRY_REPO --location=$REGION --quiet

# Delete the local container image
docker rmi $LOCAL_CONTAINER_IMAGE:latest
docker rmi $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO/$LOCAL_CONTAINER_IMAGE:v1