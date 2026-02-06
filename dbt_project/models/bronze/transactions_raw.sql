-- models/bronze/transactions_raw.sql
-- This model represents the raw, ingested data. In a real-world scenario,
-- this would likely be an external table pointing to a GCS bucket where
-- raw JSON or CSV files land. For this project, we'll simulate raw data.

{{
  config(
    materialized='table'
  )
}}

-- In a real pipeline, you would source this from your raw data loader.
-- For example: SELECT * FROM {{ source('raw_data', 'transactions') }}
-- To make this example runnable, we simulate some raw data.
SELECT
    'a1b2c3d4-e5f6-7890-1234-567890abcdef' as transaction_id,
    'user-abc-123' as user_id,
    'test.user@example.com' as user_email,
    '12345678900' as user_cpf,
    150.75 as transaction_amount,
    '2024-01-15T09:30:00Z' as transaction_timestamp,
    'credit_card' as payment_method
UNION ALL
SELECT
    'b2c3d4e5-f6a7-8901-2345-67890abcdef1' as transaction_id,
    'user-def-456' as user_id,
    'another.user@example.com' as user_email,
    '00987654321' as user_cpf,
    99.99 as transaction_amount,
    '2024-01-15T10:00:00Z' as transaction_timestamp,
    'pix' as payment_method
