--stg_multiversal_entities.sql

with source as (
    select distinct 
        nullif(json_data:is_alter_ego_of.name::string, '') as entity_name
    from {{ source('marvel_raw', 'raw_characters') }}
    where entity_name is not null
)
select
    md5(lower(entity_name)) as multiversal_entity_id,
    entity_name
from source