resource "google_service_account" "pipeline_sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "SecureGuard Lakehouse Pipeline"
  description  = "Service Account for the data pipeline to read from GCS and write to BigQuery."
}

# Grant Storage Object Admin role to the SA on the specific GCS bucket
resource "google_storage_bucket_iam_member" "gcs_access" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Grant BigQuery Data Editor role to the SA on the specific datasets
resource "google_bigquery_dataset_iam_member" "bq_access" {
  for_each = toset(var.bigquery_dataset_ids)

  project    = var.project_id
  dataset_id = each.key
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.pipeline_sa.email}"
}
