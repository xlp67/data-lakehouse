-- macros/anonymize.sql
{% macro anonymize(column_name) %}
    -- Esta macro aplica um hash no valor de uma coluna usando SHA256 e um salt secreto.
    -- O salt é recuperado das variáveis em dbt_project.yml.
    TO_HEX(SHA256(CONCAT("{{ var('PII_SALT_SECRET') }}", {{ column_name }})))
{% endmacro %}
