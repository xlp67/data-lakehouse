output "dataset_ids" {
  description = "Um mapa com os IDs dos datasets BigQuery criados."
  value = {
    for k, v in google_bigquery_dataset.datasets : k => v.dataset_id
  }
}
