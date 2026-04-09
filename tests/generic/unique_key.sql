{% test unique_key(model, column_names) %}
    select 
        {% for column_name in column_names %}
            "{{ column_name }}"::text {% if not loop.last %} || {% endif %} 
{% endfor %}
    from 
        {{ model }}
    group by 
        1
    having 
        count(*) > 1
{% endtest %}
