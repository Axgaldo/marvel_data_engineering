--{{ config(materialized='view') }}
{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source AS (
    SELECT * FROM {{ source('postgres_source', 'POSTGRES_ORDERS') }}
{% if is_incremental() %}
    WHERE _FIVETRAN_SYNCED > (SELECT MAX(LOADED_AT) FROM {{ this }})
{% endif %}
),

renamed AS (
    SELECT
        ORDER_ID,
        USER_ID,
        ADDRESS_ID,
        PROMO_ID,
        TRACKING_ID,
        SHIPPING_SERVICE,
        SHIPPING_COST::NUMBER(38,2)       AS SHIPPING_COST,
        ORDER_COST,
        ORDER_TOTAL,
        STATUS,
        CREATED_AT::TIMESTAMP_NTZ         AS CREATED_AT,
        DELIVERED_AT,
        ESTIMATED_DELIVERY_AT,
        _FIVETRAN_SYNCED                  AS LOADED_AT
    FROM source
    WHERE COALESCE(_FIVETRAN_DELETED, 'false') != 'true'
)

SELECT * FROM renamed