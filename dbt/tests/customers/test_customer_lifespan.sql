SELECT *
FROM {{ ref('int_customer_purchase_info') }}
WHERE customer_active_lifespan_days < 0