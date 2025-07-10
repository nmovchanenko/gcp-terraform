resource "google_compute_network" "main" {
  name                    = "${terraform.workspace}-vpc"
  auto_create_subnetworks = true
}
