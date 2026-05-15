--stg_universes.sql

with source as (
    select distinct
        json_data:metadata.universe as universe_name_raw
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    {{ generate_marvel_id('universe_name_raw') }} as universe_id,
    {{ clean_text('universe_name_raw' ) }} as universe_name
from source