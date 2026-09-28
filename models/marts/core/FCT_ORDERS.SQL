{{ 
    config(
    materialized = 'table',
    )
}}

WITH ORDERS AS
    (
        SELECT * FROM {{ ref('STG_ORDERS') }}
    ),
    PAYMENTS AS 
    (
        SELECT * FROM {{ ref('STG_PAYMENTS') }}
    ),
    ORDER_PAYMNETS AS
    (
        SELECT 
            ORDER_ID,
            SUM(CASE WHEN STATUS = 'success' THEN AMOUNT END) AS AMOUNT
        FROM PAYMENTS 
        GROUP BY ORDER_ID
    ),
    FINAL AS 
    (
        SELECT
            O.ORDER_ID,
            O.CUSTOMER_ID,
            O.ORDER_DATE,
            COALESCE(OP.AMOUNT,0) AS AMOUNT
        FROM ORDERS AS O 
        LEFT JOIN ORDER_PAYMNETS AS OP
        ON O.ORDER_ID = OP.ORDER_ID
    )
SELECT * FROM FINAL