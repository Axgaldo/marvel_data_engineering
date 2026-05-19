with source as (
    select 
        try_to_number(json_data:char_id::string) as character_id,
        json_data:relationships as rel_json,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }}
),

flattened as (
    select
        s.character_id,
        s.loaded_at,
        rel.value:id::int as relative_id,
        {{ clean_text('rel.value:name') }} as relative_name,
        
        -- Si hay contexto se queda, si es null limpia la categoría sin la 'S'
        case 
            when rel.value:context::string is not null and rel.value:context::string != 'null'
            then {{ clean_text('rel.value:context') }}
            else rtrim({{ clean_text('f.key') }}, 'S')
        end as relationship_context

    from source as s,
    lateral flatten(input => rel_json) f,
    lateral flatten(input => f.value) rel
    where rel.value:id is not null and relationship_context is not null
)

select distinct
    character_id,
    relative_id,
    relative_name,
    relationship_context,
    loaded_at
from flattened

qualify row_number() over (partition by character_id, relative_id, relationship_context order by loaded_at desc) = 1