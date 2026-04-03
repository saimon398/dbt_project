select distinct on (primary_genre)
	primary_genre,
	song_title,
	artist,
	total_streams_billions
from 
	{{source('ods', 'songs')}}
order by 
	primary_genre,
	total_streams_billions desc