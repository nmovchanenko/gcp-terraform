resource "google_compute_network" "main" {
  project                 = google_project.main.project_id
  name                    = "${terraform.workspace}-vpc"
  auto_create_subnetworks = true

  # This network depends on the Compute Engine API being enabled.
  depends_on = [google_project_service.compute]
}
