{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_PROMOS') }}
),

renamed AS (
    SELECT
        PROMO_ID,
        DISCOUNT::INTEGER                 AS DISCOUNT,
        STATUS,
        _FIVETRAN_SYNCED                  AS LOADED_AT
    FROM source
    WHERE COALESCE(_FIVETRAN_DELETED, 'false') != 'true'
)

SELECT * FROM renamed