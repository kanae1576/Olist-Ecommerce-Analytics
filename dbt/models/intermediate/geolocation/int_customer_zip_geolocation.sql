WITH raw_geolocation AS (
    SELECT * FROM {{ ref('stg_olist__geolocation') }}
),

deduplicated_centroids AS (
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,
        
        -- Calculate the geographic center mass (Centroid)
        AVG(latitude) AS center_latitude,
        AVG(longitude) AS center_longitude,
        
        -- Pull a standardized city and state name without breaking the group
        MAX(geolocation_city) AS city_name,
        MAX(geolocation_state) AS state_code

    FROM raw_geolocation
    GROUP BY geolocation_zip_code_prefix
)

SELECT * FROM deduplicated_centroids