with creators_from_chars as (
    select
        f.value:id::int as artist_id,
        f.value:name::string as artist_name
    from {{ source('marvel_raw', 'raw_characters') }},
    lateral flatten(input => json_data:biography.creators) f
)
select distinct artist_id, artist_name from creators_from_chars