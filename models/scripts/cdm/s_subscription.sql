-- depends_on: {{ ref("h_subscription") }}

SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(crm_subscription_id))) AS varchar) AS subscription_id,
    CAST(subscription_type AS varchar)					   AS subscription_type,
    CAST(started_at AS timestamptz)                        AS started_at,
    CAST(MD5(
        COALESCE(subscription_type, '') || '||' ||
        COALESCE(started_at::varchar, '')
    ) AS varchar)                                          AS mt_hash_diff,
    CAST(NOW() AS timestamptz)							   AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }}							   AS mt_valid_to_dttm,
    CAST(NOW() AS timestamptz)                             AS mt_load_dttm,
    true												   AS mt_active_flg,
    false 												   AS mt_deleted_flg,
    CAST('LOYALTY' AS varchar)							   AS mt_src_id
FROM 
    {{ source('paas_content_demand__loyalty', 'loyalty_subscriptions') }}
