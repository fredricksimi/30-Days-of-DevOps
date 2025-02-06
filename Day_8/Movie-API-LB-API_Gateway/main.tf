terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  # Configure authentication using a service account key file
  credentials = file("../../MyCredentials.json")   # Point this to where your credentials are locally
  region      = "us-east1"                        # Replace with desired region
  project     = "subtle-melody-449911-q2"                    # Replace with your project id
}

resource "google_cloud_run_v2_service" "default" {
  provider = google-beta
  project = "subtle-melody-449911-q2"
  name     = "cloudrun-service"
  location = "us-east1"
  deletion_protection = false
  # invoker_iam_disabled = true
  description = "The serving URL of this service will not perform any IAM check when invoked"
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-east1-docker.pkg.dev/subtle-melody-449911-q2/my-docker-repo/my-movie-app:v1"
    }
  }
}

resource "google_cloud_run_v2_service_iam_binding" "binding" {
  project = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name = google_cloud_run_v2_service.default.name
  role = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_api_gateway_api" "api_cfg" {
  project = "subtle-melody-449911-q2"
  provider = google-beta
  api_id = "my-api"
}

resource "google_api_gateway_api_config" "api_cfg" {
  project = "subtle-melody-449911-q2"
  provider = google-beta
  api = google_api_gateway_api.api_cfg.api_id
  api_config_id = "my-config"

  openapi_documents {
    document {
      path = "./apispec.yaml"
      contents = filebase64("./apispec.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider = google-beta
  project = "subtle-melody-449911-q2"
  region = "us-east1"
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = "my-gateway"
}