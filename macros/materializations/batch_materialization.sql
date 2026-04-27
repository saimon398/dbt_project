{% materialization batch_materialization, default %}

    {% set target_relation = this %}
    {% set existing_relation = load_relation(this) %}
    {% set temp_relation = make_temp_relation(target_relation) %}
    {% set column_name = config.require('column_name') %}
    {% set batch_count = config.require('batch_count') %}
    
    {{ run_hooks(pre_hooks) }}

    -- создаем временную таблицу
    {% call statement('main') %}
        create temporary table {{ temp_relation }} as (
            {{ sql }}
        )
    {% endcall %}

    -- проверяем, существует ли target-таблица
    {% if existing_relation is not none %}
        {{ adapter.drop_relation(existing_relation) }}
    {% endif  %}

    -- создаем target-таблицу заново
    {% call statement('create_target_relation') %}
        create table {{ target_relation }} (like {{ temp_relation }})
    {% endcall %}

    -- заливаем в нее данные по батчам
    {% for batch_number in range(batch_count) %}
        {% call statement('insert_batch_' ~ batch_number) %}
            insert into {{ target_relation }}
            select
                *
            from
                {{ temp_relation }}
            where
                1=1
                and abs(hashtext({{ column_name }}::text)) % {{ batch_count }} = {{ batch_number }}
        {% endcall %}
    {% endfor %}

    -- удаляем временную таблицу
    {% call statement('drop_temp_relation') %}
        drop table {{ temp_relation }}
    {% endcall %}

    {{ run_hooks(post_hooks) }}

    {{ adapter.commit() }}

    {{ return({'relations' : [target_relation]}) }}

{% endmaterialization %}