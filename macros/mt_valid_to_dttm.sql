{% macro mt_valid_to_dttm() %}
    cast('9999-12-31 23:59:59' as timestamp)
{% endmacro %}