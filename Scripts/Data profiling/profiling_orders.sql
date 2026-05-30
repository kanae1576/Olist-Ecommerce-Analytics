SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_id) AS unique_order_ids
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`;

### 2. Null rate checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(customer_id) AS non_null_customer_id,
  COUNT(*) - COUNT(customer_id) AS null_rows,
  1.0 * (COUNT(*) - COUNT(customer_id)) / COUNT(*) AS null_rate
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`;

SELECT
  COUNT(*) AS total_rows,
  COUNT(order_status) AS non_null_order_status,
  COUNT(*) - COUNT(order_status) AS null_rows,
  1.0 * (COUNT(*) - COUNT(order_status)) / COUNT(*) AS null_rate
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`;

SELECT
  COUNT(*) AS total_rows,
  COUNT(order_purchase_timestamp) AS non_null_purchase_timestamp,
  COUNT(*) - COUNT(order_purchase_timestamp) AS null_rows,
  1.0 * (COUNT(*) - COUNT(order_purchase_timestamp)) / COUNT(*) AS null_rate
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`;

### 3. Extra check for primary key uniqueness
SELECT
  order_id,
  COUNT(*) AS occurrences
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

### 4. Data sanity checks (any unexpected dates)
SELECT
  MIN(order_purchase_timestamp) AS min_purchase_ts,
  MAX(order_purchase_timestamp) AS max_purchase_ts,
  MIN(order_approved_at) AS min_approved_at,
  MAX(order_approved_at) AS max_approved_at,
  MIN(order_delivered_carrier_date) AS min_delivered_carrier_ts,
  MAX(order_delivered_carrier_date) AS max_delivered_carrier_ts,
  MIN(order_delivered_customer_date) AS min_delivered_customer_ts,
  MAX(order_delivered_customer_date) AS max_delivered_customer_ts,
  MIN(order_estimated_delivery_date) AS min_estimated_date,
  MAX(order_estimated_delivery_date) AS max_estimated_date
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`;

### 5. Order Status validity
SELECT
  order_status,
  COUNT(*) AS row_count,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct_of_total
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`
GROUP BY order_status
ORDER BY row_count DESC;

### 6. Foreign key relationship check (orders → customers)
SELECT
  COUNT(*) AS orders_missing_customers,
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders` o
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.customers` c
  ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

### 7. Delivery lifecycle logic checks
SELECT
  order_id,
  order_status,
  order_purchase_timestamp,
  order_approved_at,
  order_delivered_carrier_date,
  order_delivered_customer_date,
  order_estimated_delivery_date
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`
WHERE
  order_status = 'delivered'
  AND (
    order_delivered_customer_date IS NULL
    OR order_delivered_carrier_date IS NULL
    OR order_approved_at IS NULL
  );

SELECT
  order_id,
  order_status,
  order_purchase_timestamp,
  order_approved_at,
  order_delivered_carrier_date,
  order_delivered_customer_date,
  order_estimated_delivery_date
FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`
WHERE
  order_status = 'delivered'
  AND (
    order_delivered_customer_date < order_purchase_timestamp
    OR order_delivered_carrier_date < order_purchase_timestamp
    OR order_approved_at < order_purchase_timestamp
  );