--stg_multiversal_entities.sql

with all_entities as (
    select 
        json_data:is_alter_ego_of.name as entity_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:is_alter_ego_of.name is not null

    union

    select 
        json_data:name as entity_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:is_alter_ego_of.name is null
)

select distinct
    {{ generate_marvel_id("entity_name_raw") }} as multiversal_entity_id,
    {{ clean_text('entity_name_raw') }} as multiversal_entity_name,
    
    loaded_at
from all_entities
where entity_name_raw is not null

qualify row_number() over (partition by multiversal_entity_id order by loaded_at desc) = 1