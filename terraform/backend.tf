# Remote state storage
terraform {
  backend "gcs" {
    bucket = "secureguard-tf-state-bucket-unique" # <-- CHANGE TO A UNIQUE BUCKET NAME
    prefix = "terraform/state"
  }
}
