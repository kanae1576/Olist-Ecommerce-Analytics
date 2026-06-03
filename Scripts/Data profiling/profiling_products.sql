### Null checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(product_id) AS non_null_product_id,
  COUNT(product_category_name) AS non_null_product_category_name,
  COUNT(product_name_lenght) AS non_null_product_name_lenght,
  COUNT(product_description_lenght) AS non_null_product_description_lenght,
  COUNT(product_photos_qty) AS non_null_product_photos_qty,
  COUNT(product_weight_g) AS non_null_product_weight_g,
  COUNT(product_length_cm) AS non_null_product_length_cm,
  COUNT(product_height_cm) AS non_null_product_height_cm,
  COUNT(product_width_cm) AS non_null_product_width_cm,
FROM `ecommerce-operations-sql-audit.ecommerce_data.products`;

SELECT
  COUNT(*) AS total_rows
FROM `ecommerce-operations-sql-audit.ecommerce_data.products`
WHERE product_category_name IS NULL OR product_name_lenght IS NULL OR product_description_lenght IS NULL OR product_photos_qty IS NULL OR product_weight_g IS NULL OR product_length_cm IS NULL OR product_height_cm IS NULL OR product_width_cm IS NULL;

### Primary key check
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT(product_id)) AS unique_product_id,
FROM `ecommerce-operations-sql-audit.ecommerce_data.products`;

### Numerical column checks
SELECT
  MIN(product_name_lenght) AS min_product_name_lenght,
  MAX(product_name_lenght) AS max_product_name_lenght,
  MIN(product_description_lenght) AS min_product_description_lenght,
  MAX(product_description_lenght) AS max_product_description_lenght,
  MIN(product_photos_qty) AS min_product_photos_qty,
  MAX(product_photos_qty) AS max_product_photos_qty,
  MIN(product_weight_g) AS min_product_weight_g,
  MAX(product_weight_g) AS max_product_weight_g,
  MIN(product_length_cm) AS min_product_length_cm,
  MAX(product_length_cm) AS max_product_length_cm,
  MIN(product_height_cm) AS min_product_height_cm,
  MAX(product_height_cm) AS max_product_height_cm,
  MIN(product_width_cm) AS min_product_width_cm,
  MAX(product_width_cm) AS max_product_width_cm,
FROM `ecommerce-operations-sql-audit.ecommerce_data.products`;

### Product category
SELECT
  product_category_name,
  COUNT(*) AS occurences
FROM `ecommerce-operations-sql-audit.ecommerce_data.products`
GROUP BY product_category_name
ORDER BY occurences DESC;

### Check rows with weight = 0
SELECT *
FROM `ecommerce-operations-sql-audit.ecommerce_data.products`
WHERE product_weight_g = 0;

### FK referencing check
SELECT
  *
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items` o
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.products` p
ON o.product_id = p.product_id
WHERE p.product_category_name IS NULL OR p.product_weight_g IS NULL;

SELECT
  COUNT(p.product_id) AS occurences
FROM `ecommerce-operations-sql-audit.ecommerce_data.order_items` o
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.products` p
ON o.product_id = p.product_id
WHERE p.product_category_name IS NULL OR p.product_weight_g IS NULL
GROUP BY p.product_id
ORDER BY occurences DESC;