variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket."
  type        = string
}

variable "location" {
  description = "The location/region of the GCS bucket."
  type        = string
}

variable "storage_class" {
  description = "The storage class of the GCS bucket."
  type        = string
  default     = "STANDARD"
}

variable "lifecycle_age_days" {
  description = "Number of days after which to transition objects to Nearline storage."
  type        = number
  default     = 30
}
