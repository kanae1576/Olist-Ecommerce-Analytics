# Olist Brazilian E-Commerce Dataset - Data Dictionary

## 📋 Overview
This document is the central reference for the raw dataset. It includes table grain, keys, business context, quality issues, and initial modeling considerations.

**Dataset Period**: 2016–2018  
**Total Orders**: 99,441

## 📂 Main Tables

| Table Name | Grain | Primary/Candidate Keys | Foreign Keys | Business Purpose | Nulls | Data Quality Caveats |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`orders`** | one row per order | `order_id` | `customer_id` | Core transactional table. Central fact for order lifecycle analysis | 23 delivered orders have missing delivery cycle timestamps | 165 rows have invalid delivery timelines |
| **`customers`** | one row per customer_id | `customer_id` | None | Customer master data (shipping address at time of order) | No null values | 2,997 repeated `customer_unique_id`; 163 cities with multiple states |
| **`order_items`** | One row per item within an order | `order_id` + `order_item_id` | `order_id`, `product_id`, `seller_id` | Line-level order details (essential for revenue, freight, seller performance) | No null values | Highly skewed price/freight distribution; outliers affect aggregates |
| **`order_payments`** | One row per payment installment record per order | `order_id` + `payment_sequential` | `order_id` | Payment breakdown per order | No null values | 3 rows with `payment_type = not_defined`; 2 rows with `installments = 0`; rows with `not_defined` AND `payment_value = 0` are invalid |
| **`order_reviews`** | One row per review linked to an order | `order_id` (candidate key) | `order_id` | Customer feedback linked to orders | `review_comment_title`: ~88% null; `review_comment_message`: ~59% null | `review_id` is not globally unique; comment fields are optional and sparse |
| **`products`** | One row per product | `product_id` | None | Product master with attributes | 610 rows null in category/descriptive fields; 2 rows null in physical dimensions | 1,604 `order_items` reference products in the 611 null-heavy rows; 4 zero-weight products in `cama_mesa_banho` |
| **`sellers`** | One row per seller | `seller_id` | None | Seller master data | None | 7 of 3,095 sellers have `seller_zip_code_prefix` not in `geolocation` |

## 🗺️ Reference Tables

| Table Name | Grain | Primary/Candidate Keys | Foreign Keys | Business Purpose | Nulls | Data Quality Caveats |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`geolocation`** | One row per geolocation record | `geolocation_zip_code_prefix` (business key) | None | Geographic reference for customers & sellers | No null values | Multiple rows per zip code prefix; 8,011 distinct cities with variants; city names not normalized |
| **`product_category_name_translation`** | One row per Portuguese → English category pair | `product_category_name` (Portuguese) | None | English translation of Portuguese categories | None in all columns | 623 products have categories not in translation table |

## 📝 Notes

### orders.csv
- Total rows: 99,441
- Strong foreign key integrity
- Date range: 2016–2018, consistent with the dataset
- Clean order_status values

### customers.csv
- Total rows: 99,441
- Clean customer_state values
- Use customer_id as Primary key (representing unique purchases)
- Treat zip code as string with leading zero in staging

### order_items.csv
- Total rows: 112,650
- Strong foreign key integrity
- High skew in monetary fields, will evaluate outlier strategy during intermediate/mart layer

### order_payments.csv
- Total rows: 103,886
- Strong foreign key integrity
- Clean payment_type values
- Filter out invalid payment records, other zero-value payment rows are retained as valid edge cases and flagged for awareness

### order_reviews.csv
- Total rows: 99,224
- Strong foreign key integrity
- Valid review_creation_date values
- Deduplicate rows in staging, keeping only the most recent review per order

### products.csv
- Total rows: 32,951
- Outliers: 4 zero-weight products, concentrated in cama_mesa_banho
- Will preserve raw rows and join with translation table early in the pipeline

### sellers.csv
- Total rows: 3,095
- 7 sellers have seller_zip_code_prefix that does not exist in geolocation table
- Clean seller_state values
- Preserve raw rows, handle the 7 sellers with NULL geolocation with NULL-aware logic

### geolocation.csv
- Total rows: 1,000,163
- Clean latitude, longtitude, city and state values
- High volume table (1M+ rows), join via zip code prefix only, treat state as primary geographic dimension

### product_category_name_translation.csv
- Total rows: 71
- For products without translations, fallback to original Portuguese category name