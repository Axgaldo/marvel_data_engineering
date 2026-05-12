--stg_multiversal_entities.sql

with all_entities as (

    -- Casos donde el personaje es un "alter ego"
    select distinct 
        trim(json_data:is_alter_ego_of.name::string) as entity_name
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:is_alter_ego_of.name is not null

    union

    -- Casos donde el personaje es el "Base"
    select distinct 
        trim(json_data:name::string) as entity_name
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:is_alter_ego_of.name is null
)

select
    {{ generate_marvel_id('entity_name') }} as multiversal_entity_id,
    entity_name as multiversal_entity_name
from all_entities