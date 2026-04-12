SELECT 
    id,
    user_id,
    scooter_hw_id,
    started_at,
    finished_at,
    start_lat,
    start_lon,
    finish_lat,
    finish_lon,
    distance AS distance_m,
    cast(price AS numeric(10, 2)) / 100 AS price_rub,
    extract(EPOCH FROM (finished_at - started_at)) AS duration_s,
    finished_at <> started_at AND price = 0 AS is_free,
    date(started_at) AS trip_date
FROM 
    {{ source('instamart', 'trips') }}
