### 1. NULL rate checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(order_id) AS non_null_order_id,
  COUNT(payment_sequential) AS non_null_payment_sequential,
  COUNT(payment_type) AS non_null_payment_type,
  COUNT(payment_installments) AS non_null_customer_payment_installments,
  COUNT(payment_value) AS non_null_payment_value,
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments`;

### 2. Composite key check
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT(order_id, '-', payment_sequential)) AS unique_composite_keys
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments`;

### 3. FK check
SELECT
  COUNT(*) AS unvalid_orders
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments` op
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.orders` o
  ON op.order_id = o.order_id
  WHERE o.order_id IS NULL;

### Payment type validity
SELECT
  payment_type,
  COUNT(*) AS row_count
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments`
GROUP BY payment_type
ORDER BY row_count DESC;

### Payment installments validity
SELECT
  payment_installments,
  COUNT(*) AS row_count
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments`
GROUP BY payment_installments
ORDER BY row_count DESC;

### Payment value validity check
SELECT
  MAX(payment_value) AS max_payment_value,
  MIN(payment_value) AS min_payment_value
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments`;

SELECT *
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_payments`
WHERE payment_value = 0.0