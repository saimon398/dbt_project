SELECT 
    cast(id AS smallint) 				   AS id,
    cast(first_name AS varchar(25)) 	   AS first_name,
    cast(last_name AS varchar(25)) 		   AS last_name,
    cast(ltrim(phone, '+') AS varchar(11)) AS phone,
    cast(sex AS char(1))				   AS gender,
    birth_date
FROM 
    {{ source('instamart', 'users') }}
