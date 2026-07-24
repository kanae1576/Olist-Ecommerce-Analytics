SELECT *
FROM {{ ref('int_order_delivery') }}
WHERE delivery_days < 1