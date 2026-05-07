{{ config(
    database='MARVEL_BRONZE_DB',
    schema='STAGING'
) }}

with source as (
    select * from {{ source('marvel_raw', 'raw_release_dates') }}
    -- Filtro necesario por errores descubiertos con tests
    where json_data:comic_id is not null 
      and json_data:release_date_raw is not null
)

select
    json_data:comic_id::int as issue_id,
    json_data:release_date_raw::string as release_date_raw,
    json_data:series_id::int as series_id,
    ingested_at as loaded_at
from source