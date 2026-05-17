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