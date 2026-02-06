-- models/gold/daily_transaction_summary.sql
-- This model creates a business-level aggregate: a summary of
-- transaction volume and value per day.

{{
  config(
    materialized='view'
  )
}}

SELECT
    DATE(transaction_timestamp) as transaction_date,
    COUNT(transaction_id) as number_of_transactions,
    SUM(transaction_amount) as total_transaction_value
FROM {{ ref('transactions_cleansed') }}
GROUP BY 1
ORDER BY 1 DESC
