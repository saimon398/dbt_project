-- depends_on: {{ ref("h_user") }}
-- depends_on: {{ ref("h_subscription") }}

SELECT DISTINCT
    cast(md5(
        upper(trim(org.crm_subscription_id)) || '||' || upper(trim(org.crm_user_id))
    ) AS varchar)										       AS link_id,
    cast(md5(upper(trim(org.crm_subscription_id))) AS varchar) AS subscription_id,
    cast(md5(upper(trim(org.crm_user_id))) AS varchar)		   AS user_id,
    cast('LOYALTY' AS varchar)							       AS mt_src_id,
    cast(now() AS timestamptz)							       AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__loyalty', 'loyalty_subscriptions') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            md5(upper(trim(org.crm_subscription_id)) || '||' || upper(trim(org.crm_user_id))) = mod.link_id
    WHERE 
        mod.link_id IS null
{% endif %}
