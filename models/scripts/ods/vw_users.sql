SELECT 
    CAST(id AS smallint) 				   AS id,
    CAST(first_name AS varchar(25)) 	   AS first_name,
    CAST(last_name AS varchar(25)) 		   AS last_name,
    CAST(LTRIM(phone, '+') AS varchar(11)) AS phone,
    CAST(sex AS char(1))				   AS gender,
    birth_date
FROM 
    {{ source('instamart', 'users') }}
