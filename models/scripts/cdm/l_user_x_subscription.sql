-- depends_on: {{ ref("h_user") }}
-- depends_on: {{ ref("h_subscription") }}

SELECT DISTINCT
    CAST(MD5(
        UPPER(TRIM(org.crm_subscription_id)) || '||' || UPPER(TRIM(org.crm_user_id))
    ) AS varchar)										       AS link_id,
    CAST(MD5(UPPER(TRIM(org.crm_subscription_id))) AS varchar) AS subscription_id,
    CAST(MD5(UPPER(TRIM(org.crm_user_id))) AS varchar)		   AS user_id,
    CAST('LOYALTY' AS varchar)							       AS mt_src_id,
    CAST(NOW() AS timestamptz)							       AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__loyalty', 'loyalty_subscriptions') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            MD5(UPPER(TRIM(org.crm_subscription_id)) || '||' || UPPER(TRIM(org.crm_user_id))) = mod.link_id
    WHERE 
        mod.link_id IS null
{% endif %}
