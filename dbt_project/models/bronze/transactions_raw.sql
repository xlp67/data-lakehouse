-- models/bronze/transactions_raw.sql
-- This model is now a passthrough and placeholder.
-- In a real pipeline, an external process (like a Cloud Function or Dataflow job)
-- would load data from GCS into the source table defined in `sources.yml`.
-- This model can be used for development or testing by materializing it,
-- but it is not part of the main production data flow from silver onwards.

{{
  config(
    materialized='ephemeral' -- Ephemeral models are not created in the database
  )
}}

SELECT 1