with current_relationships as (
    select * from {{ ref('snp_relationships') }}
    where dbt_valid_to is null
)

select
    {{ dbt_utils.generate_surrogate_key(['r.character_id', 'r.relative_id', 'r.relationship_category']) }} as relationship_key,
    r.character_id as source_character_id,
    r.relative_id as target_character_id,
    r.relative_name as target_character_name,
    r.relationship_category as connection_type,
    r.relationship_context as connection_detail,
    -- Metadatos SCD2
    r.dbt_valid_from as record_valid_from,
    r.dbt_updated_at as last_version_update
from current_relationships r