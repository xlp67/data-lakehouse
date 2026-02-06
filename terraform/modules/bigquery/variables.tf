variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "location" {
  description = "The location/region for the BigQuery datasets."
  type        = string
}

variable "datasets" {
  description = "A map of BigQuery datasets to create."
  type = map(object({
    description = string
  }))
  default = {
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
