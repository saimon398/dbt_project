SELECT  *
FROM 
    {{ source('ods', 'songs') }}
WHERE
    alltime_rank < 1 OR alltime_rank > 100
