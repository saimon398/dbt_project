-- depends_on: {{ ref("h_order") }}

SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(order_id))) AS varchar) AS order_id,
    CAST(order_price AS numeric(10, 2))			AS order_price,
    CAST(order_created_dttm AS timestamptz)		AS order_created_dttm,
    CAST(order_shipped_dttm AS timestamptz)		AS order_shipped_dttm,
    CAST(shipment_type AS varchar)				AS shipment_type,
    CAST(MD5(
        COALESCE(order_price::varchar, '') || '||' ||
        COALESCE(order_created_dttm::varchar, '') || '||' ||
        COALESCE(order_shipped_dttm::varchar, '') || '||' ||
        COALESCE(shipment_type, '')
    ) AS varchar) 								AS mt_hash_diff,
    CAST(NOW() AS timestamptz)					AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }} 					AS mt_valid_to_dttm,
    CAST(NOW() AS timestamptz)					AS mt_load_dttm,
    true										AS mt_active_flg,
    false 										AS mt_deleted_flg,
    CAST('MINDBOX' AS varchar)					AS mt_src_id
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }}
