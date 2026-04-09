{% macro updated_at() %}
    cast(now() as timestamp) as updated_at
{% endmacro%}
