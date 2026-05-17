-- fct_issue_artist_credits.sql

{{
    config(
        materialized='incremental',
        unique_key=['issue_id', 'artist_id', 'role_name'],
        on_schema_change='fail',
        incremental_strategy='merge'
  )
}}

with issues as (
    select * from {{ ref('stg_issues') }}
    {% if is_incremental() %}
        where loaded_at > (select coalesce(max(loaded_at), '1900-01-01') from {{ this }})
    {% endif %}
),

story_artists as (
    select
        st.story_id,
        st.issue_id,
        sa.artist_id,
        sa.role_name,
        row_number() over (partition by st.issue_id, sa.artist_id, sa.role_name order by st.story_index) as rn
    from {{ ref('stg_stories') }} st
    join {{ ref('stg_story_artists') }} sa on st.story_id = sa.story_id
)

select
    i.issue_id,
    sa.artist_id,
    sa.role_name,
    i.loaded_at

from issues i
inner join story_artists sa on i.issue_id = sa.issue_id
where sa.rn = 1  -- Evita duplicados si un artista aparece en múltiples stories del mismo issue