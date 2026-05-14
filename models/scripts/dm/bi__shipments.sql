WITH 
cte_active_retailers AS (
    SELECT 
        retailer_id,
        retailer_name,
        retailer_type
    FROM 
        {{ ref('s_retailer') }}
    WHERE 
        1=1
        AND mt_active_flg = true
),
	
cte_active_users AS (
    SELECT 
        user_id,
        user_first_name,
        user_last_name,
        user_email
    FROM 
        {{ ref('s_user') }}
    WHERE 
        1=1
        AND mt_active_flg = true
),
	
cte_active_orders AS (
    SELECT 
        order_id,
        order_price,
        order_created_dttm,
        order_shipped_dttm,
        shipment_type
    FROM 
        {{ ref('s_order') }}
    WHERE 
        1=1
        AND mt_active_flg = true
),
	
cte_active_couriers AS (
    SELECT 
        courier_id,
        courier_type
    FROM 
        {{ ref('s_courier') }}
    WHERE 
        1=1
        AND mt_active_flg = true
)
	
SELECT 
    CAST(b.order_id AS varchar) 			  AS order_id,
    CAST(o.order_price AS numeric(10, 2))     AS order_price,
    CAST(o.order_created_dttm AS timestamptz) AS order_created_dttm,
    CAST(o.order_shipped_dttm AS timestamptz) AS order_shipped_dttm,
    CAST(o.shipment_type AS varchar)		  AS order_shipment_type,
    CAST(b.retailer_id AS varchar)		      AS retailer_id,
    CAST(r.retailer_name AS varchar)		  AS retailer_name,
    CAST(r.retailer_type AS varchar)		  AS retailer_type,
    CAST(b.user_id AS varchar) 			      AS user_id,
    CAST(u.user_first_name AS varchar)	      AS user_first_name,
    CAST(u.user_last_name AS varchar)	      AS user_last_name,
    CAST(u.user_email AS varchar)		      AS user_email,
    CAST(b.courier_id AS varchar)		      AS courier_id,
    CAST(c.courier_type AS varchar)     	  AS courier_type
FROM 
    {{ ref('b_order_x_user_x_retailer_x_courier') }} AS b
LEFT JOIN 
    cte_active_retailers 					AS r
    ON 
        b.retailer_id = r.retailer_id
LEFT JOIN 
    cte_active_users						AS u 
    ON 
        b.user_id = u.user_id
LEFT JOIN 
    cte_active_orders						AS o
    ON 
        b.order_id	= o.order_id
LEFT JOIN 
    cte_active_couriers 					AS c
    ON 
        b.courier_id = c.courier_id
