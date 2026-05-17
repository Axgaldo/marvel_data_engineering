-- stg_pronouns.sql

with raw_pronouns as (
    select distinct 
        -- Cambiamos espacios por barras antes de limpiar
        replace(json_data:biography.pronouns::string, ' ', '/') as pronouns_raw, 
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:biography.pronouns is not null
)

select
    {{ generate_marvel_id('pronouns_raw') }} as pronouns_id,
    {{ clean_text('pronouns_raw') }} as pronouns_desc,
    
    loaded_at
from raw_pronouns