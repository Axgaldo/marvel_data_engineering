--stg_multiversal_entities.sql

with all_entities as (
    select 
        {{ clean_text('json_data:is_alter_ego_of.name') }} as entity_name
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:is_alter_ego_of.name is not null

    union

    select 
        {{ clean_text('json_data:name') }} as entity_name
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:is_alter_ego_of.name is null
)

select distinct
    {{ generate_marvel_id("entity_name") }} as multiversal_entity_id,
    entity_name as multiversal_entity_name
from all_entities
where entity_name is not null