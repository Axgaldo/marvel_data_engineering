-- stg_character_capabilities.sql

with link_data as (
    select 
        json_data:char_id::int as character_id,
        f.value as capability_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.abilities) f

    union all

    select 
        json_data:char_id::int as character_id,
        f.value as capability_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.proficiencies) f
)
select
    character_id,
    {{ generate_marvel_id("capability_name_raw") }} as capability_id,
    
    loaded_at
from link_data

qualify row_number() over (partition by character_id, capability_id order by loaded_at desc) = 1