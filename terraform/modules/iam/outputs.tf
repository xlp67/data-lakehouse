output "service_account_email" {
  description = "The email of the created pipeline Service Account."
  value       = google_service_account.pipeline_sa.email
}
