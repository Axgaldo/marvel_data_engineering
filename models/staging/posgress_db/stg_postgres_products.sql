{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_PRODUCTS') }}
),

renamed AS (
    SELECT
        PRODUCT_ID,
        NAME,
        PRICE::NUMBER(38,2)               AS PRICE,
        INVENTORY::INTEGER                AS INVENTORY,
        _FIVETRAN_SYNCED                  AS LOADED_AT
    FROM source
    WHERE COALESCE(DELETED, 'false') != 'true'
)

SELECT * FROM renamed