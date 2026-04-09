SELECT 
    s.primary_genre 		 			 AS primary_genre,
    cast(s.songs_count AS smallint)		 AS songs_count, -- привели к smallint, чтобы данные соответствовали контракту
    m.artist 				 			 AS artist,
    m.song_title 			 			 AS most_popular_song_title,
    m.total_streams_billions 			 AS total_streams_billions,
    {{ updated_at() }}
FROM 
    {{ref('songs_per_genre')}} AS s
INNER JOIN 
    {{ref("most_popular_song_per_genre")}} AS m 
    ON 
        s.primary_genre = m.primary_genre
ORDER BY 
    s.songs_count DESC
