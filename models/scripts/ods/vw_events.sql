SELECT 
    CAST(event_id AS bigint)  	   AS event_id,
    CAST(user_id AS smallint) 	   AS user_id,
    CAST(timestamp AS timestamptz) AS event_dttm,
    type_id						   AS event_type
FROM 
    {{ source('instamart', 'events') }}
