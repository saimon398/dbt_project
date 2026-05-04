SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(org.courier_id))) AS varchar) AS courier_id,
    CAST(org.courier_id AS varchar)					  AS courier_src_id,
    CAST('SHOPPER' AS varchar)					      AS mt_src_id,
    CAST(NOW() AS timestamptz)					      AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__shopper', 'spree_couriers') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON
            MD5(UPPER(TRIM(org.courier_id))) = mod.courier_id
    WHERE 
        mod.courier_id IS null
{% endif %}
