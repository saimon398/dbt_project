select 
    artist_country,
    {{dbt_utils.pivot(
        'explicit',
        dbt_utils.get_column_values(source('ods', 'songs'), 'explicit'),
        prefix='pre_'
    )}}
from
    {{source('ods', 'songs')}}
group by 
    artist_country
order by 
    artist_country