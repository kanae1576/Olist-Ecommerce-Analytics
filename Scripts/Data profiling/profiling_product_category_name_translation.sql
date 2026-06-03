### Null value check
SELECT
  COUNT(*) AS total_rows,
  COUNT(product_category_name) AS non_null_product_category_name,
  COUNT(product_category_name_english) AS non_null_product_category_name_english
FROM `ecommerce-operations-sql-audit.ecommerce_data.product_category_name_translation`;

### Reference check
SELECT
  COUNT(*) AS invalid_product_categories
FROM `ecommerce-operations-sql-audit.ecommerce_data.products` p
LEFT JOIN `ecommerce-operations-sql-audit.ecommerce_data.product_category_name_translation` t
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL;