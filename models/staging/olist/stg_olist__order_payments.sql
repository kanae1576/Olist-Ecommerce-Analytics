WITH SOURCE AS (

    SELECT * FROM {{ source('olist', 'order_payments') }}

),

renamed_and_cleaned AS (

    SELECT
        -- KEYS (COMPOSITE PRIMARY KEYS)
        CAST(order_id AS STRING) AS order_id,
        CAST(payment_sequential AS INT64) AS payment_sequential,
        
        -- ATTRIBUTES
        CAST(payment_type AS STRING) AS payment_type,
        
        -- CORRECTING O INSTALLMENT ENTRIES TO A BASE BASELINE OF 1
        CASE 
            WHEN CAST(payment_installments AS INT64) = 0 THEN 1 
            ELSE CAST(payment_installments AS INT64) 
        END AS payment_installments,
        
        -- MEASURES
        CAST(payment_value AS FLOAT64) AS payment_value

    FROM SOURCE
    
    -- ELIMINATING INVALID ANOMALOUS RECORDS UNCOVERED IN PROFILING
    WHERE payment_type != 'not_defined'

)

SELECT * FROM renamed_and_cleaned