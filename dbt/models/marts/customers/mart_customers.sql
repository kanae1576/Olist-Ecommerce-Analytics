WITH customer_metrics AS (
    SELECT * FROM {{ ref('int_customer_purchase_info') }}
),

segmented_customers AS (
    SELECT *,
        NTILE(100) OVER (
            ORDER BY lifetime_spend_amount DESC
        ) AS customer_value_percentile
    FROM customer_metrics
)

SELECT
    customer_unique_id,
    total_purchase_count,
    is_repeat_customer,
    first_purchase_at,
    last_purchase_at,

    DATE_TRUNC(DATE(first_purchase_at), MONTH) AS first_purchase_month,
    DATE_TRUNC(DATE(last_purchase_at), MONTH) AS last_purchase_month,

    customer_active_lifespan_days,
    lifetime_spend_amount,
    average_order_value,

    CASE
        WHEN customer_value_percentile <= 20 THEN 'High'
        WHEN customer_value_percentile <= 50 THEN 'Medium'
        ELSE 'Low'
    END AS customer_value_segment

FROM segmented_customers