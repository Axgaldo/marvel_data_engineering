-- stg_character_species.sql

with character_species_split as (
    select 
        json_data:char_id::int as character_id,
        f.value as species_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => strtok_to_array(json_data:biography.species::string, ' ')) f
)

select
    character_id,
    {{ generate_marvel_id(['species_name_raw']) }} as species_id,
    
    loaded_at
from character_species_split
where species_name_raw is not null