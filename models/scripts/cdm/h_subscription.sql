SELECT DISTINCT
    cast(md5(upper(trim(org.crm_subscription_id))) AS varchar) AS subscription_id,
    cast(org.crm_subscription_id AS varchar)	 			   AS subscription_src_id,
    cast('LOYALTY' AS varchar)			                       AS mt_src_id,
    cast(now() AS timestamptz)					 			   AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__loyalty', 'loyalty_subscriptions') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            md5(upper(trim(org.crm_subscription_id))) = mod.subscription_id
    WHERE 
        mod.subscription_id IS null
{% endif %}
