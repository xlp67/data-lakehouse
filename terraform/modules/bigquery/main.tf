resource "google_bigquery_dataset" "datasets" {
  for_each = var.datasets

  project      = var.project_id
  dataset_id   = each.key
  friendly_name = each.key
  description  = each.value.description
  location     = var.location

  labels = {
    "managed-by" = "terraform"
  }
}
