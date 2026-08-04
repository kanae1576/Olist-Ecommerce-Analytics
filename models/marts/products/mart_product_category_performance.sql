WITH order_items AS (
    SELECT order_id, product_id, price_amount, freight_amount FROM {{ ref('stg_olist__order_items') }}
),

products AS (
    SELECT product_id, product_category_name FROM {{ ref('stg_olist__products') }}
),

translation AS (
    SELECT * FROM {{ ref('stg_olist__product_category_name_translation') }}
),

order_reviews AS (
    SELECT order_id, review_score FROM {{ ref('stg_olist__order_reviews') }}
),

order_delivery AS (
    SELECT order_id, days_delayed, delivery_days FROM {{ ref('int_order_delivery_delays') }}
),

joined_order_items AS (

    SELECT
        oi.order_id,
        oi.product_id,
        p.product_category_name,
        t.product_category_name_english,

        oi.price_amount,
        oi.freight_amount,

        r.review_score,

        d.delivery_days,
        d.days_delayed

    FROM order_items AS oi

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id

    LEFT JOIN translation AS t
        ON p.product_category_name = t.product_category_name
        
    -- -- Reviews are recorded at the order level.
    -- For orders containing multiple product categories,
    -- the review score is associated with each category represented in the order.
    LEFT JOIN order_reviews AS r
        ON oi.order_id = r.order_id

    LEFT JOIN order_delivery AS d
        ON oi.order_id = d.order_id

)

SELECT
    COALESCE(
        product_category_name_english,
        product_category_name
    ) AS product_category_name,

    SUM(price_amount) AS total_revenue,

    SUM(freight_amount) AS total_freight_amount,

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(*) AS total_items_sold,

    ROUND(AVG(price_amount), 2) AS average_selling_price,

    ROUND(AVG(freight_amount), 2) AS average_freight_amount,

    ROUND(AVG(review_score), 2) AS average_review_score,

    ROUND(AVG(delivery_days), 2) AS average_delivery_days,

    SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN days_delayed > 0 THEN order_id END),
        COUNT(DISTINCT order_id)
    ) AS late_delivery_rate

FROM joined_order_items

GROUP BY
    COALESCE(
        product_category_name_english,
        product_category_name
    )