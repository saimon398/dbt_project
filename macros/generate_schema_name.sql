{% macro generate_schema_name(custom_schema_name, node) %}
    {% set default_schema = target.schema %}
    {% if target.name == 'prod' %}
        {{ custom_schema_name | trim }}
    {% elif target.name == 'dev' %}
        {% if default_schema == 'dbt_objects' %}
            {{ custom_schema_name | trim }}
        {% else %}
            {{ default_schema | trim }}
        {% endif %}
    {% else %}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {% endif %}
{% endmacro %}
