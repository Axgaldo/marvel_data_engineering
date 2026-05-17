-- stg_species.sql

with split_species as (
    select 
        f.value as species_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    -- Dividimos la cadena por espacios y aplanamos
    lateral flatten(input => strtok_to_array(json_data:biography.species::string, ' ')) f
)

select distinct
    {{ generate_marvel_id('species_name_raw') }} as species_id,
    {{ clean_text('species_name_raw') }} as species_name,
    
    loaded_at
from split_species
where species_name is not null