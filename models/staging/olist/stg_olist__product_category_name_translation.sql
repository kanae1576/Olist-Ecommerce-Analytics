WITH source AS (

    SELECT * FROM {{ source('olist', 'product_category_name_translation') }}
    
),

renamed_and_cleaned AS (

    SELECT
        CAST(product_category_name AS STRING) AS product_category_name,
        CAST(product_category_name_english AS STRING) AS product_category_name_english

    FROM source

)

SELECT * FROM renamed_and_cleaned