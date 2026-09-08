WITH source AS (
    SELECT * FROM {{ source('olist', 'customers') }}
),

renamed_and_cleaned AS (

    SELECT
        -- Keys
        CAST(customer_id AS string) AS customer_id,
        CAST(customer_unique_id AS string) AS customer_unique_id,
        
        -- Geography (Fixing the 4-digit truncated ZIP code bug)
        lpad(CAST(customer_zip_code_prefix AS string), 5, '0') AS customer_zip_code_prefix,
        CAST(customer_city AS string) AS customer_city,
        CAST(customer_state AS string) AS customer_state

    FROM source
)

SELECT * FROM renamed_and_cleaned