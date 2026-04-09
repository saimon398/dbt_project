SELECT DISTINCT ON (primary_genre)
    primary_genre,
    song_title,
    artist,
    total_streams_billions
FROM 
    {{source('ods', 'songs')}}
ORDER BY 
    primary_genre,
    total_streams_billions DESC
