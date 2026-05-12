-- stg_species.sql

with split_species as (
    select 
        {{ clean_text('f.value') }} as species_name
    from {{ source('marvel_raw', 'raw_characters') }},
    -- Dividimos la cadena por espacios y aplanamos
    lateral flatten(input => strtok_to_array(json_data:biography.species::string, ' ')) f
)

select distinct
    {{ generate_marvel_id("species_name") }} as species_id,
    species_name
from split_species
where species_name is not null