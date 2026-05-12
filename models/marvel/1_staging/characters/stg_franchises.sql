--stg_franchises.sql

with source as (
    select distinct
        json_data:biography.franchise::string as franchise_name
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    {{ generate_marvel_id('franchise_name') }} as franchise_id,
    franchise_name
from source