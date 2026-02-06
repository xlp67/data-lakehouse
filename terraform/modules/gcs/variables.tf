variable "project_id" {
  description = "O ID do projeto Google Cloud."
  type        = string
}

variable "bucket_name" {
  description = "O nome do bucket GCS."
  type        = string
}

variable "location" {
  description = "A localização/região do bucket GCS."
  type        = string
}

variable "storage_class" {
  description = "A classe de armazenamento do bucket GCS."
  type        = string
  default     = "STANDARD"
}

variable "lifecycle_age_days" {
  description = "Número de dias após os quais os objetos devem ser movidos para o armazenamento Nearline."
  type        = number
  default     = 30
}
