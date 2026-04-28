{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('google_sheets', 'GOOGLE_SHEETS_BUDGET') }}
),

renamed AS (
    SELECT
        _ROW,
        PRODUCT_ID,
        QUANTITY::INTEGER                 AS QUANTITY,
        MONTH,
        SYNCED
    FROM source
)

SELECT * FROM renamed