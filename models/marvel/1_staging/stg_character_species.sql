-- stg_species.sql
select distinct
    md5(lower(json_data:biography.species::string)) as species_id,
    json_data:biography.species::string as species_desc
from {{ source('marvel_raw', 'raw_characters') }}
where json_data:biography.species is not null