output "gcs_lakehouse_bucket_name" {
  description = "The name of the central GCS data lake bucket."
  value       = module.gcs_lakehouse.bucket_name
}

output "bigquery_dataset_ids" {
  description = "The IDs of the provisioned BigQuery datasets."
  value       = module.bigquery_lakehouse.dataset_ids
}

output "pipeline_service_account_email" {
  description = "The email of the dedicated pipeline service account."
  value       = module.iam_pipeline.service_account_email
}
