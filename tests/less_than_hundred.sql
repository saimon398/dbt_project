select 
    *
from 
    {{ source('ods', 'songs') }}
where
    alltime_rank < 1 or alltime_rank > 100
