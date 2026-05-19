-- stg_capabilities.sql

with all_capabilities as (
    -- Unimos ambos tipos para sacar la lista única
    select 
        f.value as capability_name_raw,
        true as is_super_power,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.abilities) f
    
    union distinct

    select 
        f.value as capability_name_raw,
        false as is_super_power,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:capabilities.proficiencies) f
)
select
    {{ generate_marvel_id("capability_name_raw") }} as capability_id,
    {{ clean_text('capability_name_raw') }}  as capability_name,
    is_super_power,
    max(loaded_at) as loaded_at -- Nos quedamos con la fecha más reciente
from all_capabilities
group by 1,2,3