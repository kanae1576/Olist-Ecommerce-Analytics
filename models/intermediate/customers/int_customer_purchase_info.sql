WITH customers AS (
    SELECT * FROM {{ ref('stg_olist__customers') }}
),
orders AS (
    SELECT * FROM {{ ref('stg_olist__orders') }}
),
order_financials AS (
    SELECT * FROM {{ ref('int_order_financials') }}
),

-- Link transactions to individual human customer tokens and pull their spend figures
customer_orders_joined AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_at,
        COALESCE(f.total_payment_value, 0.0) AS order_payment_amount
    FROM orders AS o
    INNER JOIN customers AS c 
        ON o.customer_id = c.customer_id
    LEFT JOIN order_financials AS f 
        ON o.order_id = f.order_id
),

-- Calculate aggregated lifetimes and financial metrics per individual human shopper
customer_metrics AS (
    SELECT
        customer_unique_id,
        
        -- Behavioral Counts
        COUNT(order_id) AS total_purchase_count,
        
        -- Retention Flags
        CASE 
            WHEN COUNT(order_id) > 1 THEN TRUE 
            ELSE FALSE 
        END AS is_repeat_customer,
        
        -- Chronological Anchors
        MIN(order_purchase_at) AS first_purchase_at,
        MAX(order_purchase_at) AS last_purchase_at,
        
        -- Financial Lifetime Values (CLV Metrics)
        SUM(order_payment_amount) AS lifetime_spend_amount,
        AVG(order_payment_amount) AS average_order_value

    FROM customer_orders_joined
    GROUP BY customer_unique_id
),

-- Compute final chronological metrics
final_processing AS (
    SELECT
        customer_unique_id,
        total_purchase_count,
        is_repeat_customer,
        first_purchase_at,
        last_purchase_at,
        
        -- Calculate Active Lifespan
        TIMESTAMP_DIFF(last_purchase_at, first_purchase_at, DAY) AS customer_active_lifespan_days,
        
        lifetime_spend_amount,
        ROUND(average_order_value, 2) AS average_order_value
    FROM customer_metrics
)

SELECT * FROM final_processing