select 
	primary_genre,
	count(1) as songs_count
from 
	{{source('ods', 'songs')}}
group by 
	primary_genre
order by 
	songs_count desc