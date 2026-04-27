-- depends_on: {{ ref('l_user_x_order') }}
-- depends_on: {{ ref('l_retailer_x_order') }}
-- depends_on: {{ ref('l_courier_x_order') }}

SELECT
    cast(md5(
        coalesce(a.order_id, '') || '||' ||
        coalesce(a.user_id, '') || '||' ||
        coalesce(b.retailer_id, '') || '||' ||
        coalesce(c.courier_id, '')
    ) AS varchar)	                  AS bridge_link_id,
    cast(a.order_id AS varchar)       AS order_id,
    cast(a.user_id AS varchar)        AS user_id,
    cast(b.retailer_id AS varchar)    AS retailer_id,
    cast(c.courier_id AS varchar)     AS courier_id,
    cast(now() AS timestamptz)		  AS mt_load_dttm,
    cast('BUSINESS VAULT' AS varchar) AS mt_src_id
FROM 
    {{ ref('l_user_x_order') }} 	AS a
LEFT JOIN 
    {{ ref('l_retailer_x_order') }} AS b
    ON 
        a.order_id = b.order_id
LEFT JOIN 
    {{ ref('l_courier_x_order') }}  AS c 
    ON 
        a.order_id = c.order_id
{% if is_incremental() %}
    WHERE 
        1=1
        AND a.order_id NOT IN (SELECT order_id FROM {{ this }})
{% endif %}
