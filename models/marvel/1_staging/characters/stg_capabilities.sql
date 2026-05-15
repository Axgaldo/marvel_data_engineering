-- stg_capabilities.sql

with all_capabilities as (
    -- Unimos ambos tipos para sacar la lista única
    select 
        upper(f.value::string) as capability_name,
        true as is_super_power
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.abilities) f
    
    union distinct

    select 
        {{ clean_text('f.value') }} as capability_name,
        false as is_super_power
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.proficiencies) f
)
select
    {{ generate_marvel_id("capability_name") }} as capability_id,
    capability_name,
    is_super_power
from all_capabilities