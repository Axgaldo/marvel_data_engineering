-- stg_character_capabilities.sql

with link_data as (
    select 
        json_data:char_id::int as character_id,
        f.value::string as capability_name
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.abilities) f

    union all

    select 
        json_data:char_id::int as character_id,
        f.value::string as capability_name
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.proficiencies) f
)
select
    character_id,
    md5(lower(capability_name)) as capability_id
from link_data