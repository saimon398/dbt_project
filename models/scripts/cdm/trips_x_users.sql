SELECT 
    trips.id AS id,
    trips.user_id AS user_id,
    trips.scooter_hw_id AS scooter_hw_id,
    trips.started_at AS started_at,
    trips.finished_at AS finished_at,
    trips.start_lat AS start_lat,
    trips.start_lon AS start_lon,
    trips.finish_lat AS finish_lat,
    trips.finish_lon AS finish_lon,
    trips.distance_m AS distance_m,
    trips.price_rub AS price_rub,
    trips.duration_s AS duration_s,
    trips.is_free AS is_free,
    trips.trip_date AS trip_date,
    users.sex AS sex,
    CAST(EXTRACT('year' FROM AGE(trips.trip_date, users.birth_date)) AS integer) AS age,
    {{ updated_at() }}
FROM 
    {{ ref('vw_trips') }} AS trips 
INNER JOIN 
    {{ source('instamart', 'users') }} AS users 
    ON 
        trips.user_id = users.id
LIMIT 
    5
