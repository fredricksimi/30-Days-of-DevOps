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
  credentials = file("your-credentials-file-here.json")   # Point this to where your credentials are locally
  region      = "your-region-here"                        # Replace with desired region
  project     = "your-project-id-here"                    # Replace with your project id
}

resource "google_compute_instance" "my_vm" {
  name         = "your-desired-instance-name"    # Replace with desired instance name
  machine_type = "your-machine-type"             # Replace with desired machine type
  zone         = "your-desired-zone"             # Replace with desired zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Replace with desired image
    }
  }

  network_interface {
    subnetwork = "default" # Replace with desired subnetwork
  }
}