variable "project_id" {
  description = "O ID do projeto Google Cloud."
  type        = string
}

variable "location" {
  description = "A localização/região para os datasets BigQuery."
  type        = string
}

variable "datasets" {
  description = "Um mapa de datasets BigQuery a serem criados."
  type = map(object({
    description = string
  }))
  default = {
    "bronze" = {
      description = "Dados brutos e imutáveis ingeridos dos sistemas de origem."
    },
    "silver" = {
      description = "Dados limpos, validados e enriquecidos. PII é ofuscado."
    },
    "gold" = {
      description = "Agregados e features de nível de negócio, prontos para análise."
    }
  }
}
