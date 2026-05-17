-- stg_artists.sql

with artists_from_issues as (
    select distinct
        c.value:name as artist_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) s,
    lateral flatten(input => s.value:creators) c
),

artists_from_characters as (
    select distinct
        c.value:name as artist_name_raw,
        ingested_at as loaded_at
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:biography.creators) c
),

unioned as (
    select artist_name_raw, loaded_at from artists_from_issues
    union
    select artist_name_raw, loaded_at from artists_from_characters
)

select distinct
    {{ generate_marvel_id("artist_name_raw") }} as artist_id,
    {{ clean_text('artist_name_raw') }} as artist_name,
    
    max(loaded_at) as loaded_at -- Nos quedamos con la fecha más reciente

from unioned
where artist_name_raw is not null -- and artist_name like 'STAN LEE'
group by 1, 2