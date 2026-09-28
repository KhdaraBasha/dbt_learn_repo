{{
  config(
    materialized = 'view',
    )
}}
WITH CUSTOMERS AS 
    (
        SELECT
            ID AS CUSTOMER_ID,
            FIRST_NAME,
            LAST_NAME
        FROM {{ source('jaffle_shop', 'customers') }}
    )
SELECT * FROM CUSTOMERS