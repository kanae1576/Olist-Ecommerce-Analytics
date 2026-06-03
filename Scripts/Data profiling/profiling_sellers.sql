### Null checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(seller_id) AS non_null_seller_id,
  COUNT(seller_zip_code_prefix) AS non_null_seller_zip_code_prefix,
  COUNT(seller_city) AS non_null_seller_city,
  COUNT(seller_state) AS non_null_seller_state
FROM `ecommerce-operations-sql-audit.ecommerce_data.sellers`;

### Primary key check
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT(seller_id)) AS unique_seller_id
FROM `ecommerce-operations-sql-audit.ecommerce_data.sellers`;

### Seller state check
SELECT
  seller_state,
  COUNT(*) AS occurences
FROM `ecommerce-operations-sql-audit.ecommerce_data.sellers`
GROUP BY seller_state
ORDER BY occurences DESC;

SELECT
  COUNT(*) AS invalid_zip_codes
FROM `ecommerce-operations-sql-audit.ecommerce_data.sellers` s
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.geolocation` g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;