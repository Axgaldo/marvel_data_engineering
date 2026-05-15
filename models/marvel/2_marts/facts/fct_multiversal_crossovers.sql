{{
  config(
    materialized='incremental',
    unique_key='issue_id',
    on_schema_change='fail'
  )
}}

with issues_data as (
    -- EL FILTRO VA AQUÍ: Es el embudo que reduce todo desde el inicio
    select * from {{ ref('stg_issues') }}
    {% if is_incremental() %}
        where loaded_at > (select max(loaded_at) from {{ this }})
    {% endif %}
),

issue_content as (
    select 
        id.issue_id,  -- Usamos el ID ya filtrado
        u.universe_name,
        sc.character_id,
        id.loaded_at
    from issues_data as id  -- <--- Empezamos desde la tabla pequeña y filtrada
    inner join {{ ref('stg_stories') }} as s 
        on id.issue_id = s.issue_id
    inner join {{ ref('stg_story_characters') }} as sc 
        on s.story_id = sc.story_id
    inner join {{ ref('stg_characters') }} as c 
        on sc.character_id = c.character_id::string
    inner join {{ ref('stg_universes') }} as u 
        on c.universe_id = u.universe_id
),

agg_metrics as (
    select
        issue_id,
        count(distinct character_id) as total_characters_present,
        count(distinct universe_name) as total_universes_involved,
        max(loaded_at) as loaded_at
    from issue_content
    group by 1
)

select
    issue_id,
    total_characters_present,
    total_universes_involved,
    case 
        when total_universes_involved > 1 then true 
        else false 
    end as is_multiversal_event,
    (total_characters_present * total_universes_involved) as story_complexity_index,
    loaded_at
from agg_metrics