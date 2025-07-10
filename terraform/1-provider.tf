terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.34.0"
    }
  }
}

provider "google" {
  project = google_project.main.project_id
  region  = var.project_region
}