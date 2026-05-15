-- stg_formats.sql

with source as (
    select distinct
        {{ clean_text('json_data:details.format') }} as format_name
    from {{ source('marvel_raw', 'raw_comics') }}
)

select
    -- La macro se encarga de la limpieza y el ID único
    {{ generate_marvel_id('format_name') }} as format_id,
    format_name
from source
where format_name is not null