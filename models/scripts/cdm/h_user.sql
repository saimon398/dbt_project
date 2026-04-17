SELECT DISTINCT
    cast(md5(upper(trim(org.crm_user_id))) AS varchar) AS user_id,
    org.crm_user_id                                    AS user_src_id,
    cast('MINDBOX' AS varchar(7))                      AS mt_src_id,
    now()                                              AS mt_load_dttm
FROM
    {{ source('paas_content_demand__mindbox', 'spree_users') }} AS org
{% if is_incremental() %}
    LEFT JOIN
        {{ this }} AS mod
        ON 
            md5(upper(trim(org.crm_user_id))) = mod.user_id
    WHERE
        mod.user_id IS null
{% endif %}  
