variable "gcp_project_id" {
  description = "O ID do Projeto Google Cloud onde os recursos serão implantados."
  type        = string
}

variable "gcp_region" {
  description = "A região principal do Google Cloud para os recursos."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "O ambiente de implantação (ex: 'dev', 'staging', 'prod')."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "O nome do projeto, usado para nomear e etiquetar recursos."
  type        = string
  default     = "secureguard"
}
