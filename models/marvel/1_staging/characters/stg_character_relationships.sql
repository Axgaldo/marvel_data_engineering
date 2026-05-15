--stg_character_relationships.sql

with source as (
    select 
        try_to_number(json_data:char_id::string) as character_id,
        json_data:relationships as rel_json
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    character_id,
    f.key::string as relationship_category, -- 'parents', 'siblings', etc.
    rel.value:id::int as relative_id,
    {{ clean_text('rel.value:name') }} as relative_name,
    {{ clean_text('rel.value:context') }} as relationship_context, -- "Mother, Deceased, Children"

from source,
lateral flatten(input => rel_json) f,
lateral flatten(input => f.value) rel