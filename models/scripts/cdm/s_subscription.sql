SELECT DISTINCT
    cast(md5(upper(trim(crm_subscription_id))) AS varchar) AS subscription_id,
    cast(subscription_type AS varchar)					   AS subscription_type,
    cast(md5(coalesce(subscription_type, '')) AS varchar)  AS mt_hash_diff,
    cast(now() AS timestamptz)							   AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }}							   AS mt_valid_to_dttm,
    cast(now() AS timestamptz)                             AS mt_load_dttm,
    true												   AS mt_active_flg,
    false 												   AS mt_deleted_flg,
    cast('LOYALTY' AS varchar)							   AS mt_src_id
FROM 
    paas_content_demand__loyalty.loyalty_subscriptions	
