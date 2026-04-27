{% materialization scd_materialization, default %}

    -- ключ, по которому мы будем группировать версии
    {% set hub_hash_key = config.require('hub_hash_key') %}

    {% set target_relation = this %}
    {% set existing_relation = load_relation(this) %}
    {% set temp_relation = make_temp_relation(target_relation) %}

    {{ run_hooks(pre_hooks) }}

    -- создаем временную таблицу и наполняем ее данными
    {% call statement('main') %}
        create table {{ temp_relation }} as (
            {{ sql }} -- берется из файла с моделью *.sql
        )
    {% endcall %}

    -- далее смотрим, является ли это первым запуском или это --full-refresh
    {% if existing_relation is none or should_full_refresh() %}

        -- если таблица уже была (existing_relation is not None), то удаляем таблицу
        {% if existing_relation is not none %}
            {{ adapter.drop_relation(existing_relation) }}
        {% endif %}

        -- создаем целевую таблицу через CTAS (у нас ее не было или мы ее удалили, так как --full-refresh)
        {% call statement('create_target_relation') %}
            create table {{ target_relation }} as 
            select 
                *
            from 
                {{ temp_relation }}
        {% endcall %}

    -- это инкрементальный запуск
    {% else  %}

        -- вставляем новые или измененные записи 
        {% call statement('insert_new_or_changed_rows') %}

            insert into {{ target_relation }}
            select 
                org.*
            from 
                {{ temp_relation }} as org
                left join (
                    select 
                        {{ hub_hash_key }}, mt_hash_diff
                    from 
                        {{ target_relation }}
                    where 
                        mt_active_flg is true -- из модели на JOIN берем только активные записи
                ) as existing_mod
                on 
                org.{{ hub_hash_key }} = existing_mod.{{ hub_hash_key }}
            where
                1=1
                and 
                (
                    existing_mod.{{ hub_hash_key }} is null -- вставляем только те, которых еще не было
                    or
                    org.mt_hash_diff != existing_mod.mt_hash_diff -- или те, у которых не равные ключи
                )
                and not exists 
                ( -- но не вставляем, если такой хэш уже есть в таргете (даже неактивный)
                    select
                        1
                    from 
                        {{ target_relation }} as already_seen
                    where
                        1=1
                        and already_seen.{{ hub_hash_key }} = org.{{ hub_hash_key }}
                        and already_seen.mt_hash_diff = org.mt_hash_diff
                )
        
        {% endcall %}

        -- закрываем измененные записи
        {% call statement('close_changed_rows') %}
            update {{ target_relation }} as old_version_relation
            set
                mt_valid_to_dttm = new_version_relation.mt_valid_from_dttm,
                mt_active_flg = false
            from
                {{ target_relation }} as new_version_relation
            where
                1=1
                and old_version_relation.{{ hub_hash_key }} = new_version_relation.{{ hub_hash_key }}
                and old_version_relation.mt_active_flg is true 
                and new_version_relation.mt_active_flg is true
                and old_version_relation.mt_valid_from_dttm < new_version_relation.mt_valid_from_dttm

        {% endcall %}

        {# нам еще здесь нужно сделать закрытие удаленных в источнике записей #}

    {% endif %}

    -- удаляем временную таблицу
    {% call statement('drop_temp_relation') %}
        drop table if exists {{ temp_relation }}
    {% endcall %}

    {{ run_hooks(post_hooks) }}

    -- обязательно закоммитить транзакцию иначе произойдет ROLLBACK на стороне DBT
    {{ adapter.commit() }}

    {{ return({'relations' : [target_relation]}) }}

{% endmaterialization %}