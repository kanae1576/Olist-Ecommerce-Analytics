### NULL rate checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(review_id) AS non_null_review_id,
  COUNT(order_id) AS non_null_order_id,
  COUNT(review_score) AS non_null_review_score,
  COUNT(review_comment_title) AS non_null_review_comment_title,
  COUNT(review_comment_message) AS non_null_review_comment_message,
  COUNT(review_creation_date) AS non_null_review_creation_date,
  COUNT(review_answer_timestamp) AS non_null_review_answer_timestamp
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`;

### Candidate key check
SELECT review_id, COUNT(*) AS occurrences
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT order_id, COUNT(*) AS reviews_per_order
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY reviews_per_order DESC
LIMIT 50;

SELECT
  (SELECT COUNT(*) FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`) AS total_orders,
  (SELECT COUNT(DISTINCT order_id) FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`) AS orders_with_reviews,
  (SELECT COUNT(*) FROM `ecommerce-operations-sql-audit.ecommerce_data.orders`) -
  (SELECT COUNT(DISTINCT order_id) FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`) AS orders_without_reviews;

### FK integrity check
SELECT
  COUNT(*) AS invalid_reviews
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews` r
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.orders` o
  ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

### Review score check
SELECT
  review_score,
  COUNT(*) AS row_count
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`
GROUP BY review_score
ORDER BY row_count DESC;

### Date range consistency
SELECT 
  MIN(review_creation_date) AS earliest_review_creation_date,
  MAX(review_creation_date) AS latest_review_creation_date,
  MIN(review_answer_timestamp) AS earliest_review_answer_timestamp,
  MAX(review_answer_timestamp) AS latest_review_answer_timestamp
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_reviews`;