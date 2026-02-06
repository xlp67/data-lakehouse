-- models/silver/transactions_cleansed.sql
-- Este modelo limpa os dados brutos e anonimiza as colunas de PII.

{{
  config(
    materialized='table'
  )
}}

SELECT
    transaction_id,
    user_id,
    
    -- Anonimiza PII usando a macro dedicada
    {{ anonymize('user_email') }} as user_email_hashed,
    {{ anonymize('user_cpf') }} as user_cpf_hashed,
    
    -- Converte os tipos de dados para consistência
    CAST(transaction_amount AS NUMERIC) as transaction_amount,
    CAST(transaction_timestamp AS TIMESTAMP) as transaction_timestamp,
    LOWER(payment_method) as payment_method

FROM {{ source('raw_lakehouse_data', 'transactions_raw') }}
WHERE
    -- Verificação básica de qualidade de dados
    transaction_amount > 0
    AND transaction_id IS NOT NULL
