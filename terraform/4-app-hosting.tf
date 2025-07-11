# 1. Enable the Cloud Run and Artifact Registry APIs
resource "google_project_service" "run" {
  project                    = google_project.main.project_id
  service                    = "run.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "artifactregistry" {
  project                    = google_project.main.project_id
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

# 2. Create an Artifact Registry repository to store Docker images
resource "google_artifact_registry_repository" "main" {
  project       = google_project.main.project_id
  location      = var.project_region
  repository_id = "${terraform.workspace}-sveltekit-repo"
  description   = "Docker repository for SvelteKit application"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

# 2. Create the Cloud Run Service
resource "google_cloud_run_v2_service" "main" {
  project  = google_project.main.project_id
  name     = "${terraform.workspace}-sveltekit-app"
  location = var.project_region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder image
    }

    # This section configures the direct VPC connection to Cloud SQL
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }

  # Ensure the API is enabled before creating the service
  depends_on = [google_project_service.run]
}

# Enable the VPC Access API
resource "google_project_service" "vpcaccess" {
  project                    = google_project.main.project_id
  service                    = "vpcaccess.googleapis.com"
  disable_dependent_services = true
}

# 3. Create a Serverless VPC Access Connector
# This allows Cloud Run to communicate with resources in our VPC (like the database)
resource "google_vpc_access_connector" "main" {
  project       = google_project.main.project_id
  name          = "${terraform.workspace}-vpc-connector"
  region        = var.project_region
  ip_cidr_range = "10.8.0.0/28" # An unused /28 range in your VPC
  network       = google_compute_network.main.id

  depends_on = [google_project_service.vpcaccess]
}

# 4. Allow public (unauthenticated) access to the Cloud Run service
resource "google_cloud_run_v2_service_iam_binding" "allow_unauthenticated" {
  project  = google_cloud_run_v2_service.main.project
  location = google_cloud_run_v2_service.main.location
  name     = google_cloud_run_v2_service.main.name

  role    = "roles/run.invoker"
  members = ["allUsers"]
}