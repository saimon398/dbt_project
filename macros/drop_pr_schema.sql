{% macro drop_pr_schema(schema_name) %}
    {% set sql %}
        DROP SCHEMA IF EXISTS {{ schema_name }} CASCADE;
    {% endset %}
    {% do run_query(sql) %}
    {% do log("PR schema dropped: " ~ schema_name, info=True) %}
{% endmacro %}