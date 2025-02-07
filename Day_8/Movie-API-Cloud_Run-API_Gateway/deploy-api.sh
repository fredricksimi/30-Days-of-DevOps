#!/bin/bash

# Set environment variables
export PROJECT_ID="<GCP-PROJECT-ID>"       # Replace with your GCP project ID
export REGION="<GCP-REGION>"                          # GCP region i.e us-east1
export THE_SERVICE_ACCOUNT="<Your-Service-Account-Email-Here>" # The service account email

export LOCAL_CONTAINER_IMAGE="<IMAGE-NAME-HERE>"          # The name you'd like to give for your container image during the building process
export ARTIFACT_REGISTRY_REPO="<REPO-NAME-HERE>"    # The name you'd like to give for your Artifact Registry repository

export CLOUD_RUN_SERVICE_NAME="<CLOUD-RUN-SERVICE-NAME-HERE>" # The name for the Cloud Run service that will be created
export API_NAME="<API-NAME-HERE>"
export GATEWAY_NAME="<GATEWAY-NAME-HERE>"           # The name for the API Gateway that will be created
export OPENAPI_SPEC_PATH="./<API-SPEC-FILE-NAME>.yaml"         # Path to your OpenAPI spec file i.e ./apispec.yaml

##### MODIFY THE ABOVE WITH YOUR ACTUAL VALUES BEFORE PROCEEDING !!!! ############
# NO NEED TO CHANGE ANYTHING BELOW THIS SECTION AFTER MODIFYING THE VALUES ABOVE #
######## BUT YOU CAN TAKE A LOOK AT THE SCRIPT AND SEE HOW IT WORKS  #############
##################################################################################



# Build our Movie API Container image locally
echo "Build the Movie API container image"
docker build -t $LOCAL_CONTAINER_IMAGE .

echo "✅ $LOCAL_CONTAINER_IMAGE image built successfully"
echo "------------------------------------------------------------------------"

# Create a repository in Google Cloud Artifact Registry
echo "Create a repository in Google Cloud Artifact Registry"
gcloud artifacts repositories create $ARTIFACT_REGISTRY_REPO --repository-format=docker \
  --location=$REGION --description="My Docker repository" --project=$PROJECT_ID

echo "Artifact Registry Repo: $ARTIFACT_REGISTRY_REPO" >> deploy_outputs.txt
echo "✅ $ARTIFACT_REGISTRY_REPO repository created successfully"
echo "------------------------------------------------------------------------"


# Configure Docker to use gcloud CLI Authentication
echo "Configure Docker to use gcloud CLI Authentication"
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

echo "✅ Docker configured with gcloud authentication successfully"
echo "------------------------------------------------------------------------"


# Tag the container image to Artifact Registry repo
echo "Tag the container image to Artifact Registry repo"
docker tag $LOCAL_CONTAINER_IMAGE:latest \
  $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO/$LOCAL_CONTAINER_IMAGE:v1

echo "REGISTRY_MOVIE_IMAGE: $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO/$LOCAL_CONTAINER_IMAGE:v1" >> deploy_outputs.txt
export REGISTRY_MOVIE_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO/$LOCAL_CONTAINER_IMAGE:v1"

echo "✅ Container image tagged with Artifact Registry repo successfully"
echo "------------------------------------------------------------------------"


# Push the container image to the Artifact Registry repo
echo "Push the container image to the Artifact Registry repo"
docker push $REGISTRY_MOVIE_IMAGE

echo "✅ Container image pushed to Artifact Registry repo successfully"
echo "------------------------------------------------------------------------"

# Step 1: Deploy the Cloud Run service
echo "Deploying Cloud Run service..."
gcloud run deploy $CLOUD_RUN_SERVICE_NAME \
  --image $REGISTRY_MOVIE_IMAGE \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --quiet

# Step 2: Get the Cloud Run URL
CLOUD_RUN_URL=$(gcloud run services describe $CLOUD_RUN_SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --format "value(status.url)")

export THE_CLOUD_RUN_URL=CLOUD_RUN_URL
export THE_CLOUD_RUN_SERVICE_NAME=CLOUD_RUN_SERVICE_NAME

echo "Cloud run Service name: $CLOUD_RUN_SERVICE_NAME" >> deploy_outputs.txt
echo "Cloud Run Service URL: $CLOUD_RUN_URL" >> deploy_outputs.txt
echo -e "\n✅ Cloud Run Service built Successfully"
echo "Cloud Run Service URL: $CLOUD_RUN_URL"
echo "------------------------------------------------------------------------"

# Step 3: Update OpenAPI spec with Cloud Run URL
echo "Updating OpenAPI spec..."
sed -i "s|{{cloud_run_url}}|$CLOUD_RUN_URL|g" $OPENAPI_SPEC_PATH


# Step 4: Create the API Gateway config
echo "Creating API Gateway config..."
gcloud api-gateway api-configs create "${GATEWAY_NAME}-config" \
  --api=$API_NAME \
  --openapi-spec=$OPENAPI_SPEC_PATH \
  --project=$PROJECT_ID \
  --backend-auth-service-account=$THE_SERVICE_ACCOUNT

export API_CONFIG_NAME="${GATEWAY_NAME}-config"
echo "API Config name: ${GATEWAY_NAME}-config" >> deploy_outputs.txt

echo -e "\n✅ ${GATEWAY_NAME}-config API Config created successfully"
echo "------------------------------------------------------------------------"


# Step 5: View API Config details
echo "API Config details"
gcloud api-gateway api-configs describe "${GATEWAY_NAME}-config" \
  --api=$API_NAME --project=$PROJECT_ID


# Step 6: Create the API Gateway instance
echo "Creating API Gateway instance..."
gcloud api-gateway gateways create $GATEWAY_NAME-instance \
  --api=$API_NAME \
  --api-config="${GATEWAY_NAME}-config" \
  --location=$REGION \
  --project=$PROJECT_ID

export GATEWAY_INSTANCE="$GATEWAY_NAME-instance"
echo "API Name: $API_NAME" >> deploy_outputs.txt
echo "API Gateway Instance: $GATEWAY_NAME-instance" >> deploy_outputs.txt
echo -e "\n✅ $GATEWAY_NAME-instance API Gateway created successfully!"
echo "------------------------------------------------------------------------"

# Step 7: Output the Gateway URL
GATEWAY_URL=$(gcloud api-gateway gateways describe $GATEWAY_NAME-instance \
  --project=$PROJECT_ID \
  --location=$REGION \
  --format "value(defaultHostname)")

echo "API Gateway URL: https://$GATEWAY_URL" >> deploy_outputs.txt

echo -e "\n🥳🥳🥳🥳🥳🥳🥳"
echo -e "\n👉API Gateway URL: https://$GATEWAY_URL"
echo -e "\n\n"
