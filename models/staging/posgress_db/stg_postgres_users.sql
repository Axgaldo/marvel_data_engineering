--{{ config(materialized='view') }}
{{ config(
    materialized='incremental',
    unique_key='USER_ID',
    incremental_strategy='delete+insert'
) }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_USER') }}
{% if is_incremental() %}
    WHERE CREATED_AT > (SELECT MAX(CREATED_AT) FROM {{ this }})
{% endif %}
),

renamed AS (
    SELECT
        USER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        PHONE_NUMBER,
        ADDRESS_ID,
        TOTAL_ORDERS::INTEGER             AS TOTAL_ORDERS,
        CREATED_AT::TIMESTAMP_NTZ         AS CREATED_AT,
        UPDATED_AT::TIMESTAMP_NTZ         AS UPDATED_AT,
        _FIVETRAN_SYNCED                  AS LOADED_AT
    FROM source
    WHERE COALESCE(_FIVETRAN_DELETED, 'false') != 'true'
)

SELECT * FROM renamed