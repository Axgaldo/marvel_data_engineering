-- stg_character_species.sql

with character_species_split as (
    select 
        json_data:char_id::int as character_id,
        {{ clean_text('f.value') }} as species_name
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => strtok_to_array(json_data:biography.species::string, ' ')) f
)

select
    character_id,
    {{ dbt_utils.generate_surrogate_key(['species_name']) }} as species_id
from character_species_split
where species_name is not null