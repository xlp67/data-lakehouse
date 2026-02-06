# Armazenamento do estado remoto
terraform {
  backend "gcs" {
    bucket = "secureguard-tf-state-bucket-unique" # <-- ALTERE PARA UM NOME DE BUCKET ÚNICO
    prefix = "terraform/state"
  }
}
