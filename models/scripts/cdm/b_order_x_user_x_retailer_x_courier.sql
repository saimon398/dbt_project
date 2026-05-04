-- depends_on: {{ ref('l_user_x_order') }}
-- depends_on: {{ ref('l_retailer_x_order') }}
-- depends_on: {{ ref('l_courier_x_order') }}

SELECT
    CAST(MD5(
        COALESCE(a.order_id, '') || '||' ||
        COALESCE(a.user_id, '') || '||' ||
        COALESCE(b.retailer_id, '') || '||' ||
        COALESCE(c.courier_id, '')
    ) AS varchar)	                  AS bridge_link_id,
    CAST(a.order_id AS varchar)       AS order_id,
    CAST(a.user_id AS varchar)        AS user_id,
    CAST(b.retailer_id AS varchar)    AS retailer_id,
    CAST(c.courier_id AS varchar)     AS courier_id,
    CAST(NOW() AS timestamptz)		  AS mt_load_dttm,
    CAST('BUSINESS VAULT' AS varchar) AS mt_src_id
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
