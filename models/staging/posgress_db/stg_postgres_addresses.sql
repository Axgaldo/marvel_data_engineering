{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_ADDRESSES') }}
),

renamed AS (
    SELECT
        ADDRESS_ID,
        ADDRESS,
        ZIPCODE,
        STATE,
        COUNTRY,
        _FIVETRAN_SYNCED                  AS LOADED_AT
    FROM source
    WHERE COALESCE(DELETED, 'false') != 'true'
)

SELECT * FROM renamed