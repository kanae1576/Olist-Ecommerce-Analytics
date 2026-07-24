SELECT *
FROM {{ ref('int_order_financials') }}
WHERE ROUND(
        credit_card_amount
      + debit_card_amount
      + boleto_amount
      + voucher_amount,
      2
    )
    != ROUND(total_payment_value, 2)