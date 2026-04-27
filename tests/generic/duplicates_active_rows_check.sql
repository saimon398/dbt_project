{% test duplicates_active_rows_check(model, column_name) %}
    select 
        {{ column_name }}
    from 
        {{ model }}
    where 
        mt_active_flg is true 
    group by
        {{ column_name }}
    having 
        count(*) > 1
{% endtest %}