resource "google_storage_bucket" "bucket" {
  project       = var.project_id
  name          = var.bucket_name
  location      = var.location
  storage_class = var.storage_class
  force_destroy = true # Necessário para CI/CD, mas use com cautela em produção

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.lifecycle_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  labels = {
    "managed-by" = "terraform"
  }
}
