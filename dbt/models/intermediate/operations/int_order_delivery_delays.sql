WITH orders AS (
    SELECT * FROM {{ ref('stg_olist__orders') }}
),

calculated_durations AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        
        -- Base Lifecycle Timestamps
        order_purchase_at,
        shipped_at,
        delivered_at,
        estimated_delivery_at,

        -- Calculated Metrics
        CASE 
            WHEN delivered_at > estimated_delivery_at 
            THEN TIMESTAMP_DIFF(delivered_at, estimated_delivery_at, DAY)
            ELSE 0 
        END AS days_delayed,
        TIMESTAMP_DIFF(delivered_at, order_purchase_at, DAY) AS delivery_days,
        
        -- Seller handling time before giving to carrier
        TIMESTAMP_DIFF(shipped_at, order_purchase_at, DAY) AS seller_handling_days

    FROM orders
    WHERE order_status = 'delivered'
      AND delivered_at IS NOT NULL
)

SELECT * FROM calculated_durations