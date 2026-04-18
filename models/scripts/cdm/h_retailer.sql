SELECT DISTINCT
    cast(md5(upper(trim(org.retailer_code))) AS varchar) AS retailer_id,
    cast(org.retailer_code AS varchar)					 AS retailer_src_id,
    cast('MINDBOX' AS varchar)						     AS mt_src_id,
    cast(now() AS timestamptz)						     AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            md5(upper(trim(org.retailer_code))) = mod.retailer_id
    WHERE 
        mod.retailer_id IS null
{% endif %}
