--stg_character_relationships.sql

with source as (
    select 
        json_data:char_id::int as character_id,
        json_data:relationships as rel_json
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    character_id,
    f.key::string as relationship_category, -- 'parents', 'siblings', etc.
    rel.value:id::int as relative_id,
    rel.value:name::string as relative_name,
    rel.value:context::string as relationship_context, -- "Mother, Deceased"
    rel.value:url::string as relative_url
from source,
lateral flatten(input => rel_json) f,
lateral flatten(input => f.value) rel