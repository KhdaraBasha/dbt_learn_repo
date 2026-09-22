{% macro raw_source(table_name) -%}
  {{ adapter.quote(target.database) }}.{{ adapter.quote(target.schema) }}.{{ table_name }}
{%- endmacro %}
