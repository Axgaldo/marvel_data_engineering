-- stg_series.sql

with source as (
    select * from {{ source('marvel_raw', 'raw_series') }}
)

select
    -- Al haber usado STRIP_OUTER_ARRAY, accedemos directo a los campos
    json_data:series_id::int as series_id,
    {{ clean_text('json_data:title') }} as series_title,
    json_data:start_year::int as start_year,
    json_data:end_year::int as end_year,
    json_data:issue_count::int as total_issues_expected,
    json_data:series_url::string as series_url,
    
    ingested_at as loaded_at
from source