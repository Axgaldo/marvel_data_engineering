-- dim_issues.sql

with current_issues as (

    select *
    from {{ ref('snp_issues') }}
    where dbt_valid_to is null

),

issue_character_metrics as (

    select

        s.issue_id,

        count(distinct sc.character_id)
            as total_characters_present,

        count(distinct c.universe_id)
            as total_universes_involved

    from {{ ref('stg_stories') }} s

    inner join {{ ref('stg_story_characters') }} sc
        on s.story_id = sc.story_id

    inner join {{ ref('stg_characters') }} c
        on sc.character_id = c.character_id

    group by 1

),

issue_artist_metrics as (

    select

        s.issue_id,

        count(distinct sa.artist_id)
            as total_artists

    from {{ ref('stg_stories') }} s

    inner join {{ ref('stg_story_artists') }} sa
        on s.story_id = sa.story_id

    group by 1

)

select

    i.issue_id,

    i.issue_title,

    i.issue_url,

    i.cover_url,

    i.description,

    i.rating_avg,

    i.ratings_count,

    round(
        i.rating_avg
        *
        sqrt(
            i.ratings_count
            /
            nullif(
                max(i.ratings_count) over (),
                0
            )
        ),
        2
    ) as issue_weighted_rating,

    i.num_user_owns,

    i.num_user_reads,

    i.num_user_wishes,

    i.release_date,

    i.cover_date,

    i.num_pages,

    i.price_dollars,

    (
        coalesce(i.price_dollars, 0)
        *
        coalesce(i.num_user_owns, 0)
    ) as estimated_market_revenue,

    case
        when i.num_pages > 0 then
            round(i.rating_avg / i.num_pages, 4)
        else 0
    end as quality_per_page_ratio,

    s.series_title,

    f.format_name,

    i.sku,

    i.upc,

    /* =========================================
       MULTIVERSAL METRICS
    ========================================= */

    coalesce(cm.total_characters_present, 0)
        as total_characters_present,

    coalesce(cm.total_universes_involved, 0)
        as total_universes_involved,

    case
        when coalesce(cm.total_universes_involved, 0) > 1
        then true
        else false
    end as is_multiversal_event,

    (
        coalesce(cm.total_characters_present, 0)
        *
        coalesce(cm.total_universes_involved, 0)
    ) as story_complexity_index,

    /* =========================================
       CONTRIBUTION METRICS
    ========================================= */

    coalesce(am.total_artists, 0)
        as total_artists,

    (
        coalesce(am.total_artists, 0)
        +
        coalesce(cm.total_characters_present, 0)
    ) as total_contributions,

    i.loaded_at,

    i.dbt_valid_from as record_valid_from,

    i.dbt_updated_at as last_version_update

from current_issues i

left join {{ ref('stg_series') }} s
    on i.series_id = s.series_id

left join {{ ref('stg_formats') }} f
    on i.format_id = f.format_id

left join issue_character_metrics cm
    on i.issue_id = cm.issue_id

left join issue_artist_metrics am
    on i.issue_id = am.issue_id