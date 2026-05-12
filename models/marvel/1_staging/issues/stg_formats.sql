-- stg_formats.sql

with source as (
    select distinct
        json_data:details.format::string as format_name_raw
    from {{ source('marvel_raw', 'raw_comics') }}
)

select
    -- La macro se encarga de la limpieza y el ID único
    {{ generate_marvel_id('format_name_raw') }} as format_id,
    coalesce(format_name_raw, 'Unknown') as format_name
from source
where format_name_raw is not null