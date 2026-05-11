--stg_character_creators.sql

with creators_flat as (
    select
        json_data:char_id::int as character_id,
        trim(f.value:name::string) as creator_name
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:biography.creators) f
)

select
    character_id,
    {{ generate_marvel_id("creator_name") }} as artist_id
from creators_flat
where creator_name is not null