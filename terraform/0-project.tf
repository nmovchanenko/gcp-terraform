resource "random_id" "suffix" {
  byte_length = 2
}

resource "google_project" "main" {
  provider        = google.project_creator
  name            = "${var.project_name} ${terraform.workspace}"
  project_id      = "${var.project_id_prefix}-${terraform.workspace}-${random_id.suffix.hex}"
  billing_account = var.billing_account_id
}

resource "google_project_service" "compute" {
  provider                   = google.project_creator
  project                    = google_project.main.project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = true

  # This is important to prevent a race condition where Terraform
  # tries to enable the API before the project is fully ready.
  depends_on = [google_project.main]
}

resource "google_project_service" "iam_credentials" {
  provider                   = google.project_creator
  project                    = google_project.main.project_id
  service                    = "iamcredentials.googleapis.com"
  disable_dependent_services = true

  depends_on = [google_project.main]
}
