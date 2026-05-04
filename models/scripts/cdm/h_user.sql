SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(org.crm_user_id))) AS varchar) AS user_id,
    CAST(org.crm_user_id AS varchar)                   AS user_src_id,
    CAST('MINDBOX' AS varchar)                         AS mt_src_id,
    CAST(NOW() AS timestamptz)                         AS mt_load_dttm
FROM
    {{ source('paas_content_demand__mindbox', 'spree_users') }} AS org
{% if is_incremental() %}
    LEFT JOIN
        {{ this }} AS mod
        ON 
            MD5(UPPER(TRIM(org.crm_user_id))) = mod.user_id
    WHERE
        mod.user_id IS null
{% endif %}  
