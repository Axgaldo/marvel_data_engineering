--stg_character_creators.sql

with source as (
    select 
        json_data:char_id::int as character_id,
        json_data:biography.creators as creators_array
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    character_id,
    f.value:id::int as creator_id,
    f.value:name::string as creator_name
from source,
lateral flatten(input => creators_array) f