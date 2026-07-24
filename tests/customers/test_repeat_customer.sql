SELECT *
FROM {{ ref('int_customer_purchase_info') }}
WHERE
    (
        total_purchase_count > 1
        AND is_repeat_customer = FALSE
    )
    OR
    (
        total_purchase_count <= 1
        AND is_repeat_customer = TRUE
    )