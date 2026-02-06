resource "google_service_account" "pipeline_sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "SecureGuard Lakehouse Pipeline"
  description  = "Conta de Serviço para o pipeline de dados ler do GCS e escrever no BigQuery."
}

# Concede a permissão Storage Object Admin para a SA no bucket GCS específico
resource "google_storage_bucket_iam_member" "gcs_access" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Concede a permissão BigQuery Data Editor para a SA nos datasets específicos
resource "google_bigquery_dataset_iam_member" "bq_access" {
  for_each = toset(var.bigquery_dataset_ids)

  project    = var.project_id
  dataset_id = each.key
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.pipeline_sa.email}"
}
