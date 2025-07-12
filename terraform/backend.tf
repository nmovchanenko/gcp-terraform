terraform {
  backend "gcs" {
    bucket  = "development-gcp-sveltek--tfstate"
    prefix  = "terraform/state"
  }
}
