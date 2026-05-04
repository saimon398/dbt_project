-- depends_on: {{ ref("h_retailer") }}

SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(retailer_code))) AS varchar) AS retailer_id,
    CAST(retailer_name AS varchar) 					 AS retailer_name,
    CAST(retailer_type AS varchar)					 AS retailer_type,
    CAST(MD5(
        COALESCE(retailer_name, '') || '||' ||
        COALESCE(retailer_type, '')
    ) AS varchar)									 AS mt_hash_diff,
    CAST(NOW() AS timestamptz)						 AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }}						 AS mt_valid_to_dttm,
    CAST(NOW() AS timestamptz)						 AS mt_load_dttm,
    true											 AS mt_active_flg,
    false											 AS mt_deleted_flg,
    CAST('MINDBOX' AS varchar)						 AS mt_src_id
	
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }}
	