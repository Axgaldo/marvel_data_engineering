-- fct_issue_contributions.sql

{{
    config(
        materialized='incremental',
        unique_key='contribution_pk',
        on_schema_change='fail',
        incremental_strategy='merge'
    )
}}

with issues_data as (

    select
        issue_id,
        series_id,
        release_date,
        loaded_at
    from {{ ref('stg_issues') }}

    {% if is_incremental() %}
        where loaded_at >
            (
                select coalesce(max(loaded_at), '1900-01-01'::timestamp_ntz)
                from {{ this }}
            )
    {% endif %}

),

stories as (

    select
        story_id,
        issue_id
    from {{ ref('stg_stories') }}

),

/* =========================================================
   ARTIST CONTRIBUTIONS
========================================================= */

artist_contributions as (

    select

        {{ generate_marvel_id([
            "'ARTIST'",
            's.issue_id',
            'sa.artist_id',
            'sa.role_name'
        ]) }}::varchar as contribution_pk,

        s.issue_id::number as issue_id,
        id.series_id::number as series_id,

        sa.artist_id::varchar as contributor_id,
        'ARTIST'::varchar as contributor_type,

        sa.role_name::varchar as role_name,
        null::varchar as appearance_type,

        id.release_date::date as release_date,
        id.loaded_at::timestamp_ntz as loaded_at

    from stories s

    inner join issues_data id
        on s.issue_id = id.issue_id

    inner join {{ ref('stg_story_artists') }} sa
        on s.story_id = sa.story_id
),

/* =========================================================
   CHARACTER CONTRIBUTIONS
========================================================= */

character_contributions as (

    select

        {{ generate_marvel_id([
            "'CHARACTER'",
            's.issue_id',
            'sc.character_id',
            'sc.appearance_type'
        ]) }}::varchar as contribution_pk,

        s.issue_id::number as issue_id,
        id.series_id::number as series_id,

        sc.character_id::varchar as contributor_id,
        'CHARACTER'::varchar as contributor_type,

        null::varchar as role_name,
        upper(sc.appearance_type)::varchar as appearance_type,

        id.release_date::date as release_date,
        id.loaded_at::timestamp_ntz as loaded_at

    from stories s

    inner join issues_data id
        on s.issue_id = id.issue_id

    inner join {{ ref('stg_story_characters') }} sc
        on s.story_id = sc.story_id
)

/* =========================================================
   FINAL UNION (STRICT TYPING)
========================================================= */

select
    *
from artist_contributions

union all

select
    *
from character_contributions