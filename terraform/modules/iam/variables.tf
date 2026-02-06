variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "service_account_id" {
  description = "The ID for the dedicated pipeline Service Account."
  type        = string
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket the service account needs access to."
  type        = string
}

variable "bigquery_dataset_ids" {
  description = "A list of BigQuery dataset IDs the service account needs access to."
  type        = list(string)
}
