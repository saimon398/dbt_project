SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(org.crm_subscription_id))) AS varchar) AS subscription_id,
    CAST(org.crm_subscription_id AS varchar)	 			   AS subscription_src_id,
    CAST('LOYALTY' AS varchar)			                       AS mt_src_id,
    CAST(NOW() AS timestamptz)					 			   AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__loyalty', 'loyalty_subscriptions') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            MD5(UPPER(TRIM(org.crm_subscription_id))) = mod.subscription_id
    WHERE 
        mod.subscription_id IS null
{% endif %}
