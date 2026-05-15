-- set_artists.sql

with artists_from_issues as (
    select distinct upper(trim(c.value:name::string)) as artist_name
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) s,
    lateral flatten(input => s.value:creators) c
),

artists_from_characters as (
    select distinct upper(trim(c.value:name::string)) as artist_name
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:biography.creators) c
),

unioned as (
    select artist_name from artists_from_issues
    union
    select artist_name from artists_from_characters
)

select
    {{ generate_marvel_id("artist_name") }} as artist_id,
    artist_name
from unioned
where artist_name is not null -- and artist_name like 'STAN LEE'