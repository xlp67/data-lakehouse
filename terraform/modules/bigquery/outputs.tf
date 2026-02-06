output "dataset_ids" {
  description = "A map of the created BigQuery dataset IDs."
  value = {
    for k, v in google_bigquery_dataset.datasets : k => v.dataset_id
  }
}
