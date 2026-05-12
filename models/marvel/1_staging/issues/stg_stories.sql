-- stg_stories.sql

with source as (
    select 
        try_to_number(json_data:comic_id::string) as issue_id,
        f.value as story_json,
        f.index as story_index
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) f
)

select
    {{ dbt_utils.generate_surrogate_key(['issue_id', 'story_index']) }} as story_id,
    issue_id,
    story_index,
    story_json:title::string as story_title,
    try_to_number(story_json:pages::string) as story_pages
from source