output "gcs_lakehouse_bucket_name" {
  description = "O nome do bucket GCS central do data lake."
  value       = module.gcs_lakehouse.bucket_name
}

output "bigquery_dataset_ids" {
  description = "Os IDs dos datasets BigQuery provisionados."
  value       = module.bigquery_lakehouse.dataset_ids
}

output "pipeline_service_account_email" {
  description = "O email da conta de serviço dedicada do pipeline."
  value       = module.iam_pipeline.service_account_email
}
