-- stg_formats.sql

with source as (
    select distinct
        json_data:details.format as format_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_comics') }}
)

select
    {{ generate_marvel_id('format_name_raw') }} as format_id,
    {{ clean_text('format_name_raw') }}  as format_name,
    
    max(loaded_at) as loaded_at -- Nos quedamos con la fecha más reciente
from source
where format_name is not null
group by 1, 2