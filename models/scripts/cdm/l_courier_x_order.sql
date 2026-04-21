-- depends_on: {{ ref("h_courier") }}
-- depends_on: {{ ref("h_order") }}

SELECT DISTINCT
    cast(md5(
        upper(trim(org.courier_id)) || '||' || upper(trim(org.order_id))
    ) AS varchar)								      AS link_id,
    cast(md5(upper(trim(org.courier_id))) AS varchar) AS courier_id,
    cast(md5(upper(trim(org.order_id))) AS varchar)   AS order_id,
    cast('MINDBOX' AS varchar)					      AS mt_src_id,
    cast(now() AS timestamptz)					      AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            md5(upper(trim(org.courier_id)) || '||' || upper(trim(org.order_id))) = mod.link_id
    WHERE 
        mod.link_id IS null
{% endif %}
