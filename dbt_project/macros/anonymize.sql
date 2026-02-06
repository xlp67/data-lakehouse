-- macros/anonymize.sql
{% macro anonymize(column_name) %}
    -- This macro hashes a column's value using SHA256 and a secret salt.
    -- The salt is retrieved from the dbt_project.yml vars.
    TO_HEX(SHA256(CONCAT("{{ var('PII_SALT_SECRET') }}", {{ column_name }})))
{% endmacro %}
