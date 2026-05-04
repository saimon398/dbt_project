SELECT 
    primary_genre,
    CAST(COUNT(1) AS smallint) AS songs_count
FROM 
    {{source('ods', 'songs')}}
GROUP BY 
    primary_genre
ORDER BY 
    songs_count DESC
