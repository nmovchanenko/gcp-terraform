variable "project_name" {
  description = "The display name of the GCP project."
  type        = string
}

variable "project_id_prefix" {
  description = "A prefix for the GCP project ID."
  type        = string
}

variable "billing_account_id" {
  description = "The ID of the billing account to link the project to."
  type        = string
}

variable "project_region" {
  description = "The primary region for project resources."
  type        = string
  default     = "us-central1"
}

variable "db_password" {
  description = "The password for the Cloud SQL database user."
  type        = string
  sensitive   = true
  default     = "a-secure-password-for-now"
}