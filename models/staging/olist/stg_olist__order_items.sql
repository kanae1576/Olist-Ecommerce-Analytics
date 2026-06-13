WITH source AS (

    SELECT * FROM {{ source('olist', 'order_items') }}

),

renamed_and_cleaned AS (

    SELECT
        -- Keys
        CAST(order_id AS string) AS order_id,
        CAST(order_item_id AS int64) AS order_item_id,
        CAST(product_id AS string) AS product_id,
        CAST(seller_id AS string) AS seller_id,
        
        -- Date & Time
        CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_at,
        
        -- Financials (Preserved exactly as raw; no outlier capping at staging)
        CAST(price AS FLOAT64) AS price_amount,
        CAST(freight_value AS FLOAT64) AS freight_amount

    FROM source

)

SELECT * FROM renamed_and_cleaned