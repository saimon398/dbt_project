-- depends_on: {{ ref("h_courier") }}

SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(courier_id))) AS varchar) AS courier_id,
    CAST(first_name AS varchar)					  AS courier_first_name,
    CAST(last_name AS varchar)					  AS courier_last_name,
    CAST(courier_type AS varchar(4))			  AS courier_type,
    CAST(MD5(
        COALESCE(first_name, '') || '||' ||
        COALESCE(last_name, '') || '||' ||
        COALESCE(courier_type, '')
    ) AS varchar)								  AS mt_hash_diff,
    CAST(NOW() AS timestamptz)					  AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }}	                  AS mt_valid_to_dttm,
    CAST(NOW() AS timestamptz)					  AS mt_load_dttm,
    true 										  AS mt_active_flg,
    false										  AS mt_deleted_flg,
    CAST('SHOPPER' AS varchar)					  AS mt_src_id
FROM 
    {{ source('paas_content_demand__shopper', 'spree_couriers') }}					
	