WITH source AS (

    SELECT * FROM {{ source('olist', 'order_reviews') }}

),

renamed_and_cleaned AS (

    SELECT
        -- Keys
        CAST(review_id AS string) AS review_id,
        CAST(order_id AS string) AS order_id,
        
        -- Ratings & Comments
        CAST(review_score AS int64) AS review_score,
        CAST(review_comment_title AS string) AS review_comment_title,
        CAST(review_comment_message AS string) AS review_comment_message,
        
        -- Date & Time
        CAST(review_creation_date AS TIMESTAMP) AS review_created_at,
        CAST(review_answer_timestamp AS TIMESTAMP) AS review_answered_at

    FROM source

),

deduplicated AS (

    SELECT
        *,
        -- Window function to target only the most recent review per order
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY review_answered_at DESC
        ) AS row_num
    FROM renamed_and_cleaned

)

SELECT 
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_created_at,
    review_answered_at
FROM deduplicated
WHERE row_num = 1