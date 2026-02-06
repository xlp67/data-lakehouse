resource "google_service_account" "pipeline_sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "SecureGuard Lakehouse Pipeline"
  description  = "Conta de Serviço para o pipeline de dados ler do GCS e escrever no BigQuery."
}

# Concede permissões de menor privilégio no bucket GCS.
# objectCreator para escrever novos dados brutos.
# objectViewer para ler os dados para processamento.
# Isso previne a exclusão acidental ou maliciosa de dados na camada Bronze.
resource "google_storage_bucket_iam_member" "gcs_create_access" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

resource "google_storage_bucket_iam_member" "gcs_view_access" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectViewer"
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
