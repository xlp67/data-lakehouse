-- models/silver/transactions_cleansed.sql
-- This model cleanses the raw data and anonymizes PII columns.

{{
  config(
    materialized='table'
  )
}}

SELECT
    transaction_id,
    user_id,
    
    -- Anonymize PII using the dedicated macro
    {{ anonymize('user_email') }} as user_email_hashed,
    {{ anonymize('user_cpf') }} as user_cpf_hashed,
    
    -- Cast data types for consistency
    CAST(transaction_amount AS NUMERIC) as transaction_amount,
    CAST(transaction_timestamp AS TIMESTAMP) as transaction_timestamp,
    LOWER(payment_method) as payment_method

FROM {{ source('raw_lakehouse_data', 'transactions_raw') }}
WHERE
    -- Basic data quality check
    transaction_amount > 0
    AND transaction_id IS NOT NULL
