variable "project_ids" {
  description = "A map of environment names to GCP project IDs."
  type        = map(string)
}

variable "project_region" {
  description = "The primary region for project resources."
  type        = string
  default     = "us-central1"
}
