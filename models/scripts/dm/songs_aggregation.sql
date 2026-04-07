select 
	s.primary_genre 		 			 as primary_genre,
	cast(s.songs_count as smallint)		 as songs_count, -- привели к smallint, чтобы данные соответствовали контракту
	m.artist 				 			 as artist,
	m.song_title 			 			 as most_popular_song_title,
	m.total_streams_billions 			 as total_streams_billions,
	{{ updated_at() }}
from 
	{{ref('songs_per_genre')}} as s
	inner join 
	{{ref("most_popular_song_per_genre")}} as m 
	on 
	s.primary_genre = m.primary_genre
order by 
	s.songs_count desc