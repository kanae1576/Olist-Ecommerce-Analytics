SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT customer_id) AS customer_ids,
  COUNT(DISTINCT customer_unique_id) AS u_customer_ids,
  COUNT(DISTINCT customer_zip_code_prefix) AS customer_zip_code
FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`;

### 2. NULL rate checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(customer_id) AS non_null_customer_id,
  COUNT(customer_city) AS non_null_customer_city,
  COUNT(customer_state) AS non_null_customer_state,
  COUNT(customer_unique_id) AS non_null_customer_unique_id,
  COUNT(customer_zip_code_prefix) AS non_null_customer_zip_code_prefix,
FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`;

### Customer unique id consistency check
WITH customer_address_variance AS (
  SELECT
    customer_unique_id,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_state) AS distinct_states,
    COUNT(DISTINCT customer_city) AS distinct_cities,
    COUNT(DISTINCT customer_zip_code_prefix) AS distinct_zips
  FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`
  GROUP BY customer_unique_id
  HAVING COUNT(*) > 1
)

SELECT
  COUNT(*) AS total_repeat_customers,
  
  -- Test 1: Same state & city
  SUM(CASE WHEN distinct_states = 1 AND distinct_cities = 1 AND distinct_zips = 1 THEN 1 ELSE 0 END) AS matching_city_and_state_count,
  
  -- Test 2: Same state & city, different zip codes
  SUM(CASE WHEN distinct_states = 1 AND distinct_cities = 1 AND distinct_zips > 1 THEN 1 ELSE 0 END) AS shifted_zip_within_same_city_count,
  
  -- Test 3: Different location
  SUM(CASE WHEN distinct_states > 1 OR distinct_cities > 1 THEN 1 ELSE 0 END) AS completely_different_location_count
FROM customer_address_variance;

### Check customer city & state distribution
SELECT
  customer_state,
  COUNT(*) AS row_count,
  COUNT(DISTINCT customer_unique_id) AS unique_customers,
  COUNT(DISTINCT customer_zip_code_prefix) AS unique_zip_codes
FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`
GROUP BY customer_state
ORDER BY row_count DESC;

### Check zip code prefix validity
SELECT
  CAST(customer_zip_code_prefix AS STRING) AS string_zip_code,
  COUNT(*) AS invalid_record_count
FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`
WHERE 
  LENGTH(CAST(customer_zip_code_prefix AS STRING)) != 5
  OR customer_zip_code_prefix NOT BETWEEN 0 AND 99999
GROUP BY string_zip_code
ORDER BY invalid_record_count DESC;

SELECT
  customer_state,
  COUNT(DISTINCT customer_zip_code_prefix) AS distinct_4_digit_zip_count,
  COUNT(*) AS total_impacted_rows
FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`
WHERE LENGTH(CAST(customer_zip_code_prefix AS STRING)) = 4
GROUP BY customer_state
ORDER BY total_impacted_rows DESC;

### Check city consistency
SELECT
  customer_city,
  COUNT(DISTINCT customer_state) AS distinct_state_count,
  STRING_AGG(DISTINCT customer_state, ', ' ORDER BY customer_state) AS unique_states_sharing_name,
  COUNT(*) AS total_customer_rows
FROM `ecommerce-operations-sql-audit.ecommerce_data.customers`
GROUP BY customer_city
HAVING COUNT(DISTINCT customer_state) > 1
ORDER BY distinct_state_count DESC, total_customer_rows DESC
;