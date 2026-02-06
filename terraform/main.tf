locals {
  # Convenção de nomes centralizada
  data_lake_bucket_name = "${var.project_name}-lakehouse-${var.environment}"
  service_account_id    = "${var.project_name}-pipeline-${var.environment}"

  # Tags comuns para todos os recursos
  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed-by  = "terraform"
  }
}

# --- Módulo GCS ---
# Cria o bucket principal do data lakehouse
module "gcs_lakehouse" {
  source           = "./modules/gcs"
  project_id       = var.gcp_project_id
  bucket_name      = local.data_lake_bucket_name
  location         = var.gcp_region
  lifecycle_age_days = 30
}

# --- Módulo BigQuery ---
# Cria os datasets Bronze, Silver e Gold
module "bigquery_lakehouse" {
  source     = "./modules/bigquery"
  project_id = var.gcp_project_id
  location   = var.gcp_region
  datasets = {
    "bronze" = {
      description = "Raw, immutable data ingested from source systems."
    },
    "silver" = {
      description = "Cleansed, validated, and enriched data. PII is obfuscated."
    },
    "gold" = {
      description = "Business-level aggregates and features, ready for analytics."
    }
  }
}

# --- Módulo IAM ---
# Cria a conta de serviço do pipeline e concede permissões de menor privilégio
module "iam_pipeline" {
  source             = "./modules/iam"
  project_id         = var.gcp_project_id
  service_account_id = local.service_account_id
  gcs_bucket_name    = module.gcs_lakehouse.bucket_name
  bigquery_dataset_ids = values(module.bigquery_lakehouse.dataset_ids)
  
  depends_on = [
    module.gcs_lakehouse,
    module.bigquery_lakehouse
  ]
}
