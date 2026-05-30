# Brazilian E-Commerce Data Schema

## 📂Main Tables

| Table Name | Purpose | Primary/Composite Keys | Foreign Keys | Other Columns |
| :--- | :--- | :--- | :--- | :--- |
| **`customers.csv`** | Stores customer identity and location information | `customer_id` | None (Has Unique Key: `customer_unique_id`) | `customer_zip_code_prefix`, `customer_city`, `customer_state` |
| **`orders.csv`** | Core table tracking every customer order and its delivery lifecycle | `order_id` | `customer_id` | `order_status`, `order_purchase_timestamp`, `order_approved_at`, `order_delivered_carrier_date`, `order_delivered_customer_date`, `order_estimated_delivery_date` |
| **`order_items.csv`** | Stores each order item’s product, seller, price, and shipping details | `order_id` + `order_item_id` | `order_id`, `product_id`, `seller_id` | `price`, `freight_value`, `shipping_limit_date` |
| **`order_payments.csv`** | Stores payment details for each order | `order_id` + `payment_sequential` | `order_id` | `payment_type`, `payment_installments`, `payment_value` |
| **`order_reviews.csv`** | Stores customer review and feedback data for each order | None | `order_id` | `review_score`, `review_comment_title`, `review_comment_message`, `review_creation_date`, `review_answer_timestamp` |
| **`products.csv`** | Stores product attributes and physical characteristics | `product_id` | None | `product_name_length`, `product_description_length`, `product_photos_qty`, `product_weight_g`, `product_length_cm`, `product_height_cm`, `product_width_cm` |
| **`sellers.csv`** | Stores seller identity and location information | `seller_id` | None | `seller_zip_code_prefix`, `seller_city`, `seller_state` |

## 🗺️Support Tables

| Table Name | Purpose | Primary/Composite Keys | Foreign Keys | Other Columns |
| :--- | :--- | :--- | :--- | :--- |
| **`geolocation.csv`** | Maps zip code prefixes to geographic location data | None | `geolocation_zip_code_prefix` (Spatial lookup key to `customers` / `sellers`) | `geolocation_latitude`, `geolocation_longitude`, `geolocation_city`, `geolocation_state` |
| **`product_category_name_translation.csv`** | Translates product category names from Portuguese to English | `product_category_name` | None | `product_category_name_english` |

orders.csv:
- Grain: one row per order
- Total rows: 99,441
- Primary key: order_id
- Foreign key: customer_id
- Nulls: no nulls in order_id, customer_id, order_status, or order_purchase_timestamp
- Date range: 2016–2018, consistent with the dataset
- Status values: delivered, shipped, canceled, unavailable, invoiced, processing, created, approved; no unexpected statuses
- FK integrity: no orphan customer_id values
- Caveats:
    165 rows have invalid delivery timelines
    23 delivered orders have missing delivery cycle timestamps

customers.csv
- Grain: one row per customer_id
- Total rows: 99,441
- Primary key: customer_id (99,441 unique, no duplicates)
- customer_unique_id: 96,096 unique; 2,997 repeated customers
Of repeated: 2,745 same state/city/zip, 130 same state/city/different zip, 122 different locations
- Nulls: 0% in all columns
- State: 27 federal units (26 states + Federal District), no anomalies. SP dominant (40k+ orders), 13 states <1k
- Zip code prefix: 23,995 rows (3,869 values) with 4-digit format instead of 5-digit; all in SP, all <10,000 → missing leading zero
- City–state: 163 cities with multiple states; city alone is not a unique or reliable key
- Caveat: Use customer_id as PK, not customer_unique_id. Treat zip code as string with leading zero in staging

order_items.csv
- Grain: one row per item within an order
- Total rows: 112650
- Composite key: order_id + order_item_id
- Foreign keys: order_id, product_id, seller_id
- Nulls: 0% in all columns
- FK integrity: no orphan foreign key values
- Price: median 74.99 BRL; P90 ≈ 230 BRL; P95 ≈ 350 BRL; P99 ≈ 890 BRL; top 0.1% ≈ 2,110 BRL.
- Freight: median 16.26 BRL; P90 ≈ 34 BRL; P95 ≈ 45 BRL; P99 ≈ 84.5 BRL; top 0.1% ≈ 175.7 BRL.
- Caveat: highly skewed distribution; outliers will affect aggregate metrics. Metric definitions should specify whether outliers are capped or excluded.

order_payments.csv
- Grain: one row per payment installment record per order
- Total rows: 103886
- Composite key: order_id + payment_sequential
- Foreign key: order_id
- FK integrity: no orphan order_id values
- Nulls: 0% in all columns
- Payment type: mostly valid categories, with 3 not_defined rows (debit_card, credit_card, boleto, voucher)
- Payment installments: values from 1–24, plus 2 anomalous zero-installment rows
- Payment value: ranges from 0.0 to 13,664.08 BRL
- Caveat: rows with payment_type = not_defined AND payment_value = 0.0 are excluded from analytical models as invalid payment records. Other zero-value payment rows are retained as valid edge cases and flagged for awareness