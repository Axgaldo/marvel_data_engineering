{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_ORDERITEMS') }}
),

renamed AS (
    SELECT
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY::INTEGER                 AS QUANTITY
    FROM source
    WHERE COALESCE(DELETED, 'false') != 'true'
)

SELECT * FROM renamed