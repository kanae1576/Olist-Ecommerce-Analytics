SELECT *
FROM {{ ref('int_order_delivery_delays') }}
WHERE delivery_days < 0