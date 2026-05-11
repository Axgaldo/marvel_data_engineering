-- stg_story_artists.sql

--conexión triple entre ARTISTS, STORIES Y ROLES

with expanded_roles as (
    select
        s.index as story_index,
        trim(c.value:name::string) as artist_name,
        trim(r.value::string) as role_name
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) s,
    lateral flatten(input => s.value:creators) c,
    lateral flatten(input => split(c.value:role, ',')) r
)

select
    {{ dbt_utils.generate_surrogate_key(['issue_id', 'story_index']) }} as story_id,
    {{ generate_marvel_id("artist_name") }} as artist_id,
    {{ generate_marvel_id("role_name") }} as role_id,
from expanded_roles
where artist_name is not null