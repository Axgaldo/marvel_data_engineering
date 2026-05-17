--stg_character_creators.sql

with creators_flat as (
    select
        json_data:char_id::int as character_id,
        f.value:name as creator_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:biography.creators) f
)

select
    character_id,
    {{ generate_marvel_id("creator_name_raw") }} as artist_id,
    
    loaded_at
from creators_flat
where creator_name_raw is not null