output "service_account_email" {
  description = "O email da Conta de Serviço do pipeline criada."
  value       = google_service_account.pipeline_sa.email
}
