--stg_character_affiliations.sql

with source as (
    select 
        try_to_number(json_data:char_id::string) as character_id,
        json_data:affiliations as aff_json,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    character_id,
    -- Generamos el ID del equipo para normalizar
    {{ generate_marvel_id("team.value:name::string") }} as team_id,
    
    -- Si la llave contiene 'current', es True. Si no, False.
    (f.key ilike '%current%') as is_current,
    
    loaded_at
from source,
lateral flatten(input => aff_json) f,
lateral flatten(input => f.value) team
where team.value:name::string is not null