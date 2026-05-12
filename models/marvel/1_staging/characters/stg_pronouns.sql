-- stg_pronouns.sql

with raw_pronouns as (
    select distinct 
        -- Cambiamos espacios por barras antes de limpiar
        replace( {{ clean_text('json_data:biography.pronouns') }} , ' ', '/') as pronouns_desc
    from {{ source('marvel_raw', 'raw_characters') }}
    where json_data:biography.pronouns is not null
)

select
    {{ generate_marvel_id('pronouns_desc') }} as pronouns_id,
    pronouns_desc
from raw_pronouns