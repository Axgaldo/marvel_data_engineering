--stg_universes.sql

with source as (
    select distinct
        {{ clean_text('json_data:biography.universe') }} as universe_name
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['universe_name']) }} as universe_id,
    universe_name
from source