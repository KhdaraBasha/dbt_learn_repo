{# {{
  config(
    materialized = 'table',
    )
}} #}
-- DIM_CUSTOMERS.SQL
WITH CUSTOMERS AS 
    (
        SELECT *
        FROM {{ ref('STG_CUSTOMERS') }}
    ),
    ORDERS AS 
    (
        SELECT *
        FROM {{ ref('FCT_ORDERS') }}
    ),
    CUSTOMER_ORDERS AS 
    (
        SELECT 
            CUSTOMER_ID,
            MIN(ORDER_DATE) AS FIRST_ORDER_DATE,
            MAX(ORDER_DATE) AS MOST_RECENT_ORDER_DATE,
            COUNT(ORDER_ID) AS NUMBER_OF_ORDERS,
            SUM(AMOUNT) AS LIFETIME_VALUE
        FROM ORDERS
        GROUP BY CUSTOMER_ID
    ),
    FINAL AS
    (
        SELECT 
            CS.CUSTOMER_ID,
            CS.FIRST_NAME,
            CS.LAST_NAME,
            CO.FIRST_ORDER_DATE,
            CO.MOST_RECENT_ORDER_DATE,
            COALESCE(CO.NUMBER_OF_ORDERS,0) AS NUMBER_OF_ORDERS,
            CO.LIFETIME_VALUE
        FROM CUSTOMERS CS 
        LEFT JOIN CUSTOMER_ORDERS CO 
        ON CS.CUSTOMER_ID = CO.CUSTOMER_ID
    )
SELECT * FROM FINAL