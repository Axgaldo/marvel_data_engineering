{{
  config(
    materialized='incremental',
    unique_key='engagement_pk',
    on_schema_change='fail'
  )
}}

with issues_data as (
    select 
        *
    from {{ ref('stg_issues') }}
    {% if is_incremental() %}
        where loaded_at > (select max(loaded_at) from {{ this }})
    {% endif %}
),

stories as (
    select story_id, issue_id from {{ ref('stg_stories') }}
),

story_characters as (
    -- stg_story_characters tiene story_id y character_id
    select 
        story_id, 
        character_id,
        appearance_type
    from {{ ref('stg_story_characters') }}
),

characters_master as (
    select character_id from {{ ref('stg_characters') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['sc.character_id', 's.issue_id']) }} as engagement_pk,
    sc.character_id,
    s.issue_id,
    id.series_id,
    sc.appearance_type,
    
    id.rating_avg,
    id.ratings_count,
    id.num_user_owns,
    id.num_user_reads,
    id.num_user_wishes,
    
    (id.num_user_reads * 0.5 + id.num_user_owns * 0.3 + id.num_user_wishes * 0.2) as engagement_index,

    (id.num_user_reads * 0.5 + id.num_user_owns * 0.3) * case 
        when upper(sc.appearance_type) = 'PRIMARY' then 1.0
        when upper(sc.appearance_type) = 'SUPPORTING' then 0.5
        when upper(sc.appearance_type) = 'CAMEO' then 0.1
        else 0.2 
    end as weighted_engagement_score,

    id.release_date,
    
    id.loaded_at

from issues_data as id
inner join stories as s 
    on id.issue_id = s.issue_id
inner join story_characters as sc 
    on s.story_id = sc.story_id
inner join characters_master as c 
    on sc.character_id = c.character_id