### NULL rate check
SELECT
  COUNT(*) AS total_rows,
  COUNT(geolocation_zip_code_prefix) AS total_gzip_code,
  COUNT(geolocation_lat) AS total_glat,
  COUNT(geolocation_lng) AS total_glng,
  COUNT(geolocation_city) AS total_gcity,
  COUNT(geolocation_state) AS total_gstate
FROM `ecommerce-operations-sql-audit.ecommerce_data.geolocation`;

### Composite key checks
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT(geolocation_zip_code_prefix)) AS unique_gzip_code,
  COUNT(DISTINCT(geolocation_lat)) AS unique_glat,
  COUNT(DISTINCT(geolocation_lng)) AS unique_glng,
  COUNT(DISTINCT(geolocation_city)) AS unique_gcity,
  COUNT(DISTINCT(geolocation_state)) AS unique_gstate
FROM `ecommerce-operations-sql-audit.ecommerce_data.geolocation`;

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT(geolocation_zip_code_prefix, '-', geolocation_lat, '-', geolocation_lng, '-', geolocation_city, '-', geolocation_state)) AS unique_composite
FROM `ecommerce-operations-sql-audit.ecommerce_data.geolocation`;

### Latitude & longtitude value checks
SELECT
  MIN(geolocation_lat) AS min_glat,
  MAX(geolocation_lat) AS max_glat,
  MIN(geolocation_lng) AS min_glng,
  MAX(geolocation_lng) AS max_glng
FROM `ecommerce-operations-sql-audit.ecommerce_data.geolocation`;

### City and state distribution
SELECT
  geolocation_city,
  COUNT(*) AS occurences
FROM `ecommerce-operations-sql-audit.ecommerce_data.geolocation`
GROUP BY geolocation_city
ORDER BY occurences DESC;

SELECT
  geolocation_state,
  COUNT(*) AS occurences
FROM `ecommerce-operations-sql-audit.ecommerce_data.geolocation`
GROUP BY geolocation_state
ORDER BY occurences DESC;
