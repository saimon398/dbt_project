select 
	primary_genre,
	cast(count(1) as smallint) as songs_count
from 
	{{source('ods', 'songs')}}
group by 
	primary_genre
order by 
	songs_count desc