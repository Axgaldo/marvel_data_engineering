--{{ config(materialized='view') }}
{{ config(
    materialized='incremental',
    unique_key='ADDRESS_ID',
    incremental_strategy='merge'
) }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_ADDRESSES') }}
{% if is_incremental() %}
    WHERE _FIVETRAN_SYNCED > (SELECT MAX(LOADED_AT) FROM {{ this }})
{% endif %}
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
    --WHERE COALESCE(DELETED, 'false') != 'true'

)

SELECT * FROM renamed