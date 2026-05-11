-- stg_stories.sql


with source as (
    select 
        json_data:comic_id::int as issue_id,
        f.value as story_json,
        f.index as story_index
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) f
)

select
    {{ dbt_utils.generate_surrogate_key(['issue_id', 'story_index']) }} as story_id, -- NO USAMOS MACRO DE GENERAR ID PORQUE SON NÚMEROS
    issue_id,
    story_json:title::string as story_title,
    nullif(story_json:pages::string, '')::int as story_pages
from source