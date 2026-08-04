WITH customers AS (
    SELECT * FROM {{ ref('stg_olist__customers') }}
),

order_delivery AS (
    SELECT * FROM {{ ref('int_order_delivery_delays') }}
),

order_financials AS (
    SELECT * FROM {{ ref('int_order_financials') }}
)

SELECT
    -- Keys
    f.order_id,
    f.customer_id,
    c.customer_unique_id,

    -- Order information
    f.order_status,

    -- Dates
    d.order_purchase_at,
    d.shipped_at,
    d.delivered_at,
    d.estimated_delivery_at,

    -- Financial metrics
    f.total_item_price,
    f.total_freight_price,
    f.total_payment_value,
    f.total_items_count,
    f.max_payment_installments,
    f.credit_card_amount,
    f.debit_card_amount,
    f.boleto_amount,
    f.voucher_amount,

    -- Delivery metrics
    d.delivery_days,
    d.days_delayed,
    d.seller_handling_days,

    -- Customer geography
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state

FROM order_financials AS f

LEFT JOIN order_delivery AS d
    ON f.order_id = d.order_id

LEFT JOIN customers AS c
    ON f.customer_id = c.customer_id