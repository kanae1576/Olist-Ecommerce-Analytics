### 1. NULL rate checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(order_id) AS non_null_order_id,
  COUNT(order_item_id) AS non_null_order_item_id,
  COUNT(product_id) AS non_null_product_id,
  COUNT(seller_id) AS non_null_seller_id,
  COUNT(shipping_limit_date) AS non_null_shipping_limit_date,
  COUNT(price) AS non_null_price,
  COUNT(freight_value) AS non_null_freight_value
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items`;

### 2. Composite key check
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT(order_id, '-', order_item_id)) AS unique_composite_keys
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items`;

### 3. FK integrity
SELECT
  COUNT(*) AS invalid_orders,
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items` i
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.orders` o
  ON i.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
  COUNT(*) AS invalid_products,
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items` o
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.products` p
  ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT
  COUNT(*) AS invalid_sellers,
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items` o
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.sellers` s
  ON o.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

### 4. Price check
SELECT
  MIN(price) AS min_price,
  MAX(price) AS max_price,
  MIN(freight_value) AS min_freight_value,
  MAX(freight_value) AS max_freight_value
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items`;

SELECT
  -- Price Distribution Array
  price_quantiles[OFFSET(5000)] AS median_price,
  price_quantiles[OFFSET(9000)] AS p90_price,
  price_quantiles[OFFSET(9500)] AS p95_price,
  price_quantiles[OFFSET(9900)] AS p99_price,
  price_quantiles[OFFSET(9990)] AS p999_price,
  
  -- Freight Distribution Array
  freight_quantiles[OFFSET(5000)] AS median_freight,
  freight_quantiles[OFFSET(9000)] AS p90_freight,
  freight_quantiles[OFFSET(9500)] AS p95_freight,
  freight_quantiles[OFFSET(9900)] AS p99_freight,
  freight_quantiles[OFFSET(9990)] AS p999_freight
FROM (
  SELECT 
    APPROX_QUANTILES(price, 10000) AS price_quantiles,
    APPROX_QUANTILES(freight_value, 10000) AS freight_quantiles
  FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items`
);