SELECT DISTINCT
    cast(md5(upper(trim(courier_id))) AS varchar) AS courier_id,
    cast(first_name AS varchar)					  AS courier_first_name,
    cast(last_name AS varchar)					  AS courier_last_name,
    cast(courier_type AS varchar(4))			  AS courier_type,
    cast(md5(
        coalesce(first_name, '') || '||' ||
        coalesce(last_name, '') || '||' ||
        coalesce(courier_type, '')
    ) AS varchar)								  AS mt_hash_diff,
    cast(now() AS timestamptz)					  AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }}	                  AS mt_valid_to_dttm,
    cast(now() AS timestamptz)					  AS mt_load_dttm,
    true 										  AS mt_active_flg,
    false										  AS mt_deleted_flg,
    cast('SHOPPER' AS varchar)					  AS mt_src_id
FROM 
    {{ source('paas_content_demand__shopper', 'spree_couriers') }}					
	