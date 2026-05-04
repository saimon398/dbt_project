-- depends_on: {{ ref("h_user") }}

SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(crm_user_id))) AS varchar) AS user_id,
    CAST(COALESCE(first_name, '') AS varchar)	   AS user_first_name,
    CAST(COALESCE(last_name, '') AS varchar)	   AS user_last_name,
    CAST(COALESCE(email, '') AS varchar)		   AS user_email,
    CAST(COALESCE(phone, '') AS varchar)		   AS user_phone,
    CAST(MD5(
        COALESCE(email, '') || '||' ||
        COALESCE(first_name, '') || '||' ||
        COALESCE(last_name, '')	|| '||' ||
        COALESCE(phone, '')
    ) AS varchar) 						 		   AS mt_hash_diff,
    CAST(valid_from AS timestamptz)				   AS mt_valid_from_dttm,
    CAST(null AS timestamptz)                      AS mt_valid_to_dttm,
    CAST(NOW() AS timestamptz)					   AS mt_load_dttm,
    true 										   AS mt_active_flg,
    false 										   AS mt_deleted_flg,
    CAST('MINDBOX' AS varchar)					   AS mt_src_id
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_users') }}
