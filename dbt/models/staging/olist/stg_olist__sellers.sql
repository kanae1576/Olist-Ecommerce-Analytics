WITH source AS (

    SELECT * FROM {{ source('olist', 'sellers') }}

),

renamed_and_cleaned AS (

    SELECT
        -- Keys
        CAST(seller_id AS string) AS seller_id,
        
        -- Geography (Enforcing consistent 5-digit ZIP formatting)
        lpad(CAST(seller_zip_code_prefix AS string), 5, '0') AS seller_zip_code_prefix,
        CAST(seller_city AS string) AS seller_city,
        CAST(seller_state AS string) AS seller_state

    FROM source

)

SELECT * FROM renamed_and_cleaned