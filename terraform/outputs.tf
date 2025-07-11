output "project_region" {
  description = "The GCP region where resources are deployed."
  value       = var.project_region
}

output "project_id" {
  description = "The ID of the created GCP project."
  value       = google_project.main.project_id
}

output "repository_id" {
  description = "The ID of the Artifact Registry repository."
  value       = google_artifact_registry_repository.main.repository_id
}
