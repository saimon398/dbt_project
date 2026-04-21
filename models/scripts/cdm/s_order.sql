-- depends_on: {{ ref("h_order") }}

SELECT DISTINCT
    cast(md5(upper(trim(order_id))) AS varchar) AS order_id,
    cast(order_price AS numeric(10, 2))			AS order_price,
    cast(order_created_dttm AS timestamptz)		AS order_created_dttm,
    cast(order_shipped_dttm AS timestamptz)		AS order_shipped_dttm,
    cast(shipment_type AS varchar)				AS shipment_type,
    cast(md5(
        coalesce(order_price::varchar, '') || '||' ||
        coalesce(order_created_dttm::varchar, '') || '||' ||
        coalesce(order_shipped_dttm::varchar, '') || '||' ||
        coalesce(shipment_type, '')
    ) AS varchar) 								AS mt_hash_diff,
    cast(now() AS timestamptz)					AS mt_valid_from_dttm,
    {{ mt_valid_to_dttm() }} 					AS mt_valid_to_dttm,
    cast(now() AS timestamptz)					AS mt_load_dttm,
    true										AS mt_active_flg,
    false 										AS mt_deleted_flg,
    cast('MINDBOX' AS varchar)					AS mt_src_id
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }}
