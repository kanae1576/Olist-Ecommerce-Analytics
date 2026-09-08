SELECT 
    is_repeat_customer,
    COUNT(customer_unique_id) AS total_shoppers,
    ROUND(AVG(total_purchase_count), 2) AS avg_purchases,
    ROUND(AVG(customer_active_lifespan_days), 1) AS avg_active_days,
    ROUND(AVG(lifetime_spend_amount), 2) AS avg_lifetime_value
FROM {{ ref('int_customer_purchase_info') }}
GROUP BY is_repeat_customer