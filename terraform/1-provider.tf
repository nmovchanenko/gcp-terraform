terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# This provider is used ONLY to create the project itself.
# It authenticates at the user level, without a project context.
provider "google" {
  alias = "project_creator"
}

# This is the default provider for all other resources.
provider "google" {
  region = var.project_region
}
