SELECT 
    cast(event_id AS bigint)  	   AS event_id,
    cast(user_id AS smallint) 	   AS user_id,
    cast(timestamp AS timestamptz) AS event_dttm,
    type_id						   AS event_type
FROM 
    {{ source('instamart', 'events') }}
