-- models/bronze/transactions_raw.sql
-- Este modelo é agora um passthrough e um placeholder.
-- Em um pipeline real, um processo externo (como uma Cloud Function ou um job do Dataflow)
-- carregaria os dados do GCS para a tabela de origem (source) definida em `sources.yml`.
-- Este modelo pode ser usado para desenvolvimento ou teste ao ser materializado,
-- mas não faz parte do fluxo principal de dados de produção a partir da camada silver.

{{
  config(
    materialized='ephemeral' -- Modelos efêmeros não são criados no banco de dados
  )
}}

SELECT 1