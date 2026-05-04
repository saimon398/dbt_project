SELECT DISTINCT
    CAST(MD5(UPPER(TRIM(org.retailer_code))) AS varchar) AS retailer_id,
    CAST(org.retailer_code AS varchar)					 AS retailer_src_id,
    CAST('MINDBOX' AS varchar)						     AS mt_src_id,
    CAST(NOW() AS timestamptz)						     AS mt_load_dttm
FROM 
    {{ source('paas_content_demand__mindbox', 'spree_orders') }} AS org
{% if is_incremental() %}
    LEFT JOIN 
        {{ this }} AS mod
        ON 
            MD5(UPPER(TRIM(org.retailer_code))) = mod.retailer_id
    WHERE 
        mod.retailer_id IS null
{% endif %}
