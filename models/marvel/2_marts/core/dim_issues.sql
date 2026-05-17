-- dim_issues.sql

with current_issues as (

    select *
    from {{ ref('snp_issues') }}
    where dbt_valid_to is null

),

issue_multiversal_metrics as (

    select
        s.issue_id,

        count(distinct sc.character_id) as total_characters_present,

        count(distinct c.universe_id) as total_universes_involved

    from {{ ref('stg_stories') }} s

    inner join {{ ref('stg_story_characters') }} sc
        on s.story_id = sc.story_id

    inner join {{ ref('stg_characters') }} c
        on sc.character_id = c.character_id::string

    group by 1

)

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

    -- MÉTRICAS MULTIVERSALES

    coalesce(m.total_characters_present, 0)
        as total_characters_present,

    coalesce(m.total_universes_involved, 0)
        as total_universes_involved,

    case
        when coalesce(m.total_universes_involved, 0) > 1
        then true
        else false
    end as is_multiversal_event,

    (
        coalesce(m.total_characters_present, 0)
        *
        coalesce(m.total_universes_involved, 0)
    ) as story_complexity_index,

    i.loaded_at,

    i.dbt_valid_from as record_valid_from,
    i.dbt_updated_at as last_version_update

from current_issues i

left join {{ ref('stg_series') }} s
    on i.series_id = s.series_id

left join {{ ref('stg_formats') }} f
    on i.format_id = f.format_id

left join issue_multiversal_metrics m
    on i.issue_id = m.issue_id