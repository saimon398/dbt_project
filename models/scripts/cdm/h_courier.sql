SELECT DISTINCT
    cast(md5(upper(trim(org.courier_id))) AS varchar) AS courier_id,
    cast(org.courier_id AS varchar)					  AS courier_src_id,
    cast('SHOPPER' AS varchar)					      AS mt_src_id,
    cast(now() AS timestamptz)					      AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__shopper', 'spree_couriers') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON
            md5(upper(trim(org.courier_id))) = mod.courier_id
    WHERE 
        mod.courier_id IS null
{% endif %}
