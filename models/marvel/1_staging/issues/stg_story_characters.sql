-- stg_story_characters.sql

with source as (
    select 
        try_to_number(json_data:comic_id::string) as issue_id,
        f.index as story_index,
        char.value as char_json,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) f,
    lateral flatten(input => f.value:characters) char
)

select

    -- FK a la historia (misma lógica que la PK de stg_stories)
    {{ generate_marvel_id(['issue_id', 'story_index']) }} as story_id,
    
    -- FK al personaje: EXTRAER EL ID DE LA URL
    regexp_substr(
        char_json:url::string, 
        '/character/([0-9]+)', 
        1, 1, 'e'
    )::int as character_id,
    
    -- Metadato de la relación
    {{ clean_text('char_json:type') }} as appearance_type, -- "MAIN", "SUPPORTING", "CAMEO"
    
    loaded_at
from source