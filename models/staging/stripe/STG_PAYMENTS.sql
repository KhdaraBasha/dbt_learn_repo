{{ 
  config(
    materialized = 'view',
    )
}}

WITH PAYMENTS AS 
    (
        SELECT 
            ID AS PAYMENT_ID,
            ORDERID AS ORDER_ID,
            PAYMENTMETHOD AS PAYMENT_METHOD,
            STATUS,
            AMOUNT,
            CREATED AS CREATED_AT,
            CURRENT_TIMESTAMP AS _LOAD_DATE
        FROM {{ source('stripe', 'payment') }}
    )
SELECT * FROM PAYMENTS