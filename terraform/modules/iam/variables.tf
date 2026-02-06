variable "project_id" {
  description = "O ID do projeto Google Cloud."
  type        = string
}

variable "service_account_id" {
  description = "O ID para a Conta de Serviço dedicada do pipeline."
  type        = string
}

variable "gcs_bucket_name" {
  description = "O nome do bucket GCS ao qual a conta de serviço precisa de acesso."
  type        = string
}

variable "bigquery_dataset_ids" {
  description = "Uma lista de IDs de datasets do BigQuery aos quais a conta de serviço precisa de acesso."
  type        = list(string)
}
