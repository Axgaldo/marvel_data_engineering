{{
  config(
    materialized='incremental',
    unique_key='artist_performance_pk',
    on_schema_change='fail'
  )
}}

with issues_data as (
    select * from {{ ref('stg_issues') }}
    {% if is_incremental() %}
        where loaded_at > (select max(loaded_at) from {{ this }})
    {% endif %}
),

stories as (
    -- Esta es la tabla puente que tiene el issue_id
    select story_id, issue_id from {{ ref('stg_stories') }}
),

credits_data as (
    -- stg_story_artists NO tiene issue_id, tiene story_id
    select 
        story_id,
        artist_id,
        role_name
    from {{ ref('stg_story_artists') }}
),

artists_master as (
    select artist_id from {{ ref('stg_artists') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['cd.artist_id', 's.issue_id', 'cd.role_name']) }} as artist_performance_pk,
    cd.artist_id,
    s.issue_id,
    cd.role_name,
    
    id.num_user_owns as total_owners,
    id.num_user_reads as total_readers,
    id.num_user_wishes as total_wishers,
    id.rating_avg as issue_rating,
    id.price_dollars,
    id.num_pages,

    (coalesce(id.price_dollars, 0) * id.num_user_owns) as estimated_market_revenue,

    case 
        when id.num_pages > 0 then (id.rating_avg / id.num_pages) 
        else 0 
    end as quality_per_page_ratio,
    
    (id.num_user_reads * 0.7 + id.num_user_owns * 0.3) as artist_impact_score,
    
    id.release_date,
    
    id.loaded_at

from issues_data as id
inner join stories as s 
    on id.issue_id = s.issue_id
inner join credits_data as cd 
    on s.story_id = cd.story_id
inner join artists_master as am 
    on cd.artist_id = am.artist_id