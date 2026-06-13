WITH source AS (

    SELECT * FROM {{ source('olist', 'geolocation') }}

),

renamed_and_cleaned AS (

    SELECT
        -- Geography Keys
        LPAD(CAST(geolocation_zip_code_prefix AS STRING), 5, '0') AS geolocation_zip_code_prefix,
        
        -- Coordinates
        CAST(geolocation_lat AS FLOAT64) AS latitude,
        CAST(geolocation_lng AS FLOAT64) AS longitude,
        
        -- Demographics
        CAST(geolocation_city AS STRING) AS geolocation_city,
        CAST(geolocation_state AS STRING) AS geolocation_state

    FROM source

)

SELECT * FROM renamed_and_cleaned