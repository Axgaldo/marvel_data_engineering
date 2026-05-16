--stg_franchises.sql

with source as (
    select distinct
        {{ clean_text('json_data:biography.franchise') }} as franchise_name
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['franchise_name']) }} as franchise_id,
    franchise_name,
    
    current_timestamp() as loaded_at
from source