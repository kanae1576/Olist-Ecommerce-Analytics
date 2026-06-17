WITH orders AS (
    SELECT * FROM {{ ref('stg_olist__orders') }}
), order_items AS (
    SELECT * FROM {{ ref('stg_olist__order_items') }}
), order_payments AS (
    SELECT * FROM {{ ref('stg_olist__order_payments') }}
),

-- Aggregate line-level prices and freight values per order
aggregated_items AS (
    SELECT
        order_id,
        SUM(price_amount) AS total_item_price,
        SUM(freight_amount) AS total_freight_price,
        COUNT(order_item_id) AS total_items_count
    FROM order_items
    GROUP BY order_id
),

-- Pivot payment types into individual amount columns per order
aggregated_payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        MAX(payment_installments) AS max_payment_installments,
        
        -- Conditional Aggregations for each specified payment type
        SUM(CASE WHEN payment_type = 'credit_card' THEN payment_value ELSE 0.0 END) AS credit_card_amount,
        SUM(CASE WHEN payment_type = 'debit_card' THEN payment_value ELSE 0.0 END) AS debit_card_amount,
        SUM(CASE WHEN payment_type = 'boleto' THEN payment_value ELSE 0.0 END) AS boleto_amount,
        SUM(CASE WHEN payment_type = 'voucher' THEN payment_value ELSE 0.0 END) AS voucher_amount
        
    FROM order_payments
    GROUP BY order_id
),

-- Combine everything back to primary orders directory anchor
final_financial_rollup AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,
        
        -- Aggregated Monetary Fields
        COALESCE(i.total_item_price, 0.0) AS total_item_price,
        COALESCE(i.total_freight_price, 0.0) AS total_freight_price,
        COALESCE(p.total_payment_value, 0.0) AS total_payment_value,
        COALESCE(i.total_items_count, 0) AS total_items_count,
        COALESCE(p.max_payment_installments, 1) AS max_payment_installments,
        
        -- Pivoted Payment Method breakdown amounts
        COALESCE(p.credit_card_amount, 0.0) AS credit_card_amount,
        COALESCE(p.debit_card_amount, 0.0) AS debit_card_amount,
        COALESCE(p.boleto_amount, 0.0) AS boleto_amount,
        COALESCE(p.voucher_amount, 0.0) AS voucher_amount

    FROM orders AS o
    LEFT JOIN aggregated_items AS i 
        ON o.order_id = i.order_id
    LEFT JOIN aggregated_payments AS p 
        ON o.order_id = p.order_id
)

SELECT * FROM final_financial_rollup