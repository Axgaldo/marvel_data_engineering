--stg_franchises.sql

with source as (
    select distinct
        json_data:biography.franchise::string as franchise_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    {{ generate_marvel_id(['franchise_name_raw']) }} as franchise_id,
    {{ clean_text('franchise_name_raw') }} as franchise_name,
    
    loaded_at
from source

qualify row_number() over (partition by franchise_id order by loaded_at desc) = 1