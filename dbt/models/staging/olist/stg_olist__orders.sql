WITH source AS (
    SELECT * FROM {{ source('olist', 'orders')}}
),

renamed_and_cleaned AS (
    SELECT
        -- KEYS
        CAST(order_id AS STRING) AS order_id,
        CAST(customer_id AS STRING) AS customer_id,
        
        -- STATUS
        CAST(order_status AS STRING) AS order_status,
        
        -- TIMESTAMPS (CASTING STRING CORES TO NATIVE TIMESTAMP OBJECTS)
        CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_at,
        CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
        CAST(order_delivered_carrier_date AS TIMESTAMP) AS shipped_at,
        CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_at,
        CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_delivery_at

    FROM SOURCE

)

SELECT * FROM renamed_and_cleaned