variable "gcp_project_id" {
  description = "The Google Cloud Project ID to deploy resources into."
  type        = string
}

variable "gcp_region" {
  description = "The primary Google Cloud region for resources."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'staging', 'prod')."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project, used for naming and tagging resources."
  type        = string
  default     = "secureguard"
}
