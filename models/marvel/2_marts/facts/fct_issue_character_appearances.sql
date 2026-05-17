-- fct_issue_character_appearances.sql

{{
    config(
        materialized='incremental',
        unique_key=['issue_id', 'character_id'],
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

story_characters as (
    select
        st.story_id,
        st.issue_id,
        sc.character_id,
        sc.appearance_type,
        row_number() over (partition by st.issue_id, sc.character_id order by st.story_index) as rn
    from {{ ref('stg_stories') }} st
    join {{ ref('stg_story_characters') }} sc on st.story_id = sc.story_id
)

select
    i.issue_id,
    sc.character_id,
    sc.appearance_type,
    i.loaded_at

from issues i
inner join story_characters sc on i.issue_id = sc.issue_id
where sc.rn = 1  -- Evita duplicados si un personaje aparece en múltiples stories del mismo issue