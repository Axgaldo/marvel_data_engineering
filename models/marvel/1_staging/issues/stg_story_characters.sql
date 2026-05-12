-- stg_story_characters.sql

with source as (
    select 
        try_to_number(json_data:comic_id::string) as issue_id,
        f.index as story_index,
        char.value as char_json
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) f,
    lateral flatten(input => f.value:characters) char
)

select
    -- FK a la historia (misma lógica que la PK de stg_stories)
    {{ dbt_utils.generate_surrogate_key(['issue_id', 'story_index']) }} as story_id,
    
    -- FK al personaje (usamos la macro porque es por nombre/entidad)
    {{ generate_marvel_id("char_json:name::string") }} as character_id,
    
    -- Metadato de la relación
    char_json:type::string as appearance_type -- "Main", "Supporting", "Cameo"
from source