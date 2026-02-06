output "bucket_name" {
  description = "O nome do bucket GCS criado."
  value       = google_storage_bucket.bucket.name
}
