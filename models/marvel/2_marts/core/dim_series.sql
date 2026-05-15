with series as (
    select * from {{ ref('stg_series') }}
)

select
    series_id,
    series_title,
    start_year,
    end_year,
    -- Lógica de estado de la serie
    case 
        when end_year is null or end_year >= 2026 then 'ONGOING'
        else 'ENDED'
    end as series_status,
    
    -- Cálculo de longevidad
    coalesce(end_year, 2026) - start_year as total_years_run,
    
    total_issues_expected,
    series_url,

    loaded_at
from series