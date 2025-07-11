# 1.  Enable APIs required for Cloud SQL and Private Service Networking
resource "google_project_service" "sqladmin" {
  project                    = google_project.main.project_id
  service                    = "sqladmin.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "servicenetworking" {
  project                    = google_project.main.project_id
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = true
}

# 2. Configure Private Service Access for the VPC
resource "google_compute_global_address" "private_ip_address" {
  project       = google_project.main.project_id
  name          = "private-ip-for-google-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 16
  network       = google_compute_network.main.id
  depends_on    = [google_project_service.servicenetworking]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_project_service.servicenetworking]
}

# 3. Create the Cloud SQL Instance for PostgreSQL
resource "google_sql_database_instance" "main" {
  project             = google_project.main.project_id
  name                = "${terraform.workspace}-db-instance"
  database_version    = "POSTGRES_14"
  region              = var.project_region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }
    backup_configuration {
      enabled = true
    }
  }

  # This ensures the VPC peering is established before the instance is created
  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.sqladmin
  ]
}

# 4. Create a specific database (schema) for the application
resource "google_sql_database" "app_db" {
  project  = google_project.main.project_id
  instance = google_sql_database_instance.main.name
  name     = "${terraform.workspace}_app_db"
}

# 5. Create a user for the application to connect with
resource "google_sql_user" "app_user" {
  project  = google_project.main.project_id
  instance = google_sql_database_instance.main.name
  name     = "app_user"
  password = var.db_password # Assumes you have a variable for the password
}