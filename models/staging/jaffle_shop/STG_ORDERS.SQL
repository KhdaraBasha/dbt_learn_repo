 {{
   config(
     materialized = 'view',
     )
 }}
 WITH ORDERS AS 
    (
        SELECT
            ID AS ORDER_ID,
            USER_ID AS CUSTOMER_ID,
            ORDER_DATE,
            STATUS
        FROM RAW.JAFFLE_SHOP.ORDERS
    )
SELECT * FROM ORDERS