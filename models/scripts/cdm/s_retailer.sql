-- depends_on: {{ ref("h_retailer") }}

SELECT DISTINCT
    cast(md5(upper(trim(retailer_code))) AS varchar) AS retailer_id,
    cast(retailer_name AS varchar) 					 AS retailer_name,
    cast(retailer_type AS varchar)					 AS retailer_type,
    cast(md5(
        coalesce(retailer_name, '') || '||' ||
        coalesce(retailer_type, '')
    ) AS varchar)									 AS mt_hash_diff,
    cast(now() AS timestamptz)						 AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }}						 AS mt_valid_to_dttm,
    cast(now() AS timestamptz)						 AS mt_load_dttm,
    true											 AS mt_active_flg,
    false											 AS mt_deleted_flg,
    cast('MINDBOX' AS varchar)						 AS mt_src_id
	
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }}
	