
with current_issues as (
    select * from {{ ref('snp_issues') }}
    where dbt_valid_to is null 
),
select
    i.issue_id,
    i.issue_title,
    i.issue_url,
    i.cover_url,
    i.description,
    i.num_user_owns,
    i.num_user_reads,
    i.num_user_wishes,
    i.release_date,
    i.cover_date,
    i.num_pages,
    i.price_dollars,
    s.series_title,
    f.format_name,
    i.sku,
    i.upc,
    
    i.loaded_at,

    i.dbt_valid_from as record_valid_from,
    i.dbt_updated_at as last_version_update
from current_issues i
left join {{ ref('stg_series') }} s on i.series_id = s.series_id
left join {{ ref('stg_formats') }} f on i.format_id = f.format_id