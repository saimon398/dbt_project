SELECT 
    artist_country,
    {{dbt_utils.pivot(
        'explicit',
        dbt_utils.get_column_values(source('ods', 'songs'), 'explicit'),
        prefix='pre_'
    )}}
FROM
    {{source('ods', 'songs')}}
GROUP BY 
    artist_country
ORDER BY 
    artist_country
