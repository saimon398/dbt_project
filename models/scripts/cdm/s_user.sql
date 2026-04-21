-- depends_on: {{ ref("h_user") }}

SELECT DISTINCT
    cast(md5(upper(trim(crm_user_id))) AS varchar) AS user_id,
    cast(coalesce(first_name, '') AS varchar)	   AS user_first_name,
    cast(coalesce(last_name, '') AS varchar)	   AS user_last_name,
    cast(coalesce(email, '') AS varchar)		   AS user_email,
    cast(coalesce(phone, '') AS varchar)		   AS user_phone,
    cast(md5(
        coalesce(email, '') || '||' ||
        coalesce(first_name, '') || '||' ||
        coalesce(last_name, '')	|| '||' ||
        coalesce(phone, '')
    ) AS varchar) 						 		   AS mt_hash_diff,
    cast(valid_from AS timestamptz)				   AS mt_valid_from_dttm,
    null			                               AS mt_valid_to_dttm,
    cast(now() AS timestamptz)					   AS mt_load_dttm,
    true 										   AS mt_active_flg,
    false 										   AS mt_deleted_flg,
    cast('MINDBOX' AS varchar)					   AS mt_src_id
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_users') }}
