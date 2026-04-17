SELECT DISTINCT
    cast(md5(upper(trim(org.order_id))) AS varchar) AS order_id,
    cast(org.order_id AS varchar) 				    AS order_src_id,
    cast('MINDBOX' AS varchar)			            AS mt_src_id,
    cast(now() AS timestamptz)					    AS mt_load_dttm
FROM
    {{ source('paas_content_demand__mindbox', 'spree_orders') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            md5(upper(trim(org.order_id))) = mod.order_id
    WHERE
        mod.order_id IS null
{% endif %}
