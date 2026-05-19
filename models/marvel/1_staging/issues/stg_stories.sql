-- stg_stories.sql

with source as (
    select 
        try_to_number(json_data:comic_id::string) as issue_id,
        f.value as story_json,
        f.index as story_index,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) f
)

select
    {{ generate_marvel_id(['issue_id', 'story_index']) }} as story_id,
    issue_id,
    story_index,
    {{ clean_text('story_json:title') }} as story_title,
    try_to_number(story_json:pages::string) as story_pages,
    
    loaded_at

from source

qualify row_number() over (partition by story_id order by loaded_at desc) = 1