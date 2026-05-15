with relations as (
    select * from {{ ref('stg_character_relationships') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['character_id', 'relative_id', 'relationship_category']) }} as relationship_key,
    character_id as source_character_id,
    relative_id as target_character_id,
    relative_name as target_character_name,
    relationship_category as connection_type, -- Ej: FAMILY, ENEMY, ALTER_EGO
    relationship_context as connection_detail -- Ej: Brother, Archenemy,

    loaded_at
from relations