-- depends_on: {{ ref("h_user") }}
-- depends_on: {{ ref("h_order") }}

SELECT DISTINCT
    CAST(MD5(
        UPPER(TRIM(org.customer_id)) || '||' || UPPER(TRIM(org.order_id))
    ) AS varchar)			 					       AS link_id,
    CAST(MD5(UPPER(TRIM(org.customer_id))) AS varchar) AS user_id,
    CAST(MD5(UPPER(TRIM(org.order_id))) AS varchar)    AS order_id,
    CAST('MINDBOX' AS varchar)					       AS mt_src_id,
    CAST(NOW() AS timestamptz)					       AS mt_load_dttm
FROM
    {{ source('paas_content_demand__mindbox', 'spree_orders') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            MD5(UPPER(TRIM(org.customer_id)) || '||' || UPPER(TRIM(org.order_id))) = mod.link_id
    WHERE 
        mod.link_id IS null
{% endif %}					
