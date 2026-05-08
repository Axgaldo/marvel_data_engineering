-- stg_species.sql

select distinct
    md5(lower(json_data:biography.pronouns::string)) as pronouns_id,
    json_data:biography.pronouns::string as pronouns_desc
from {{ source('marvel_raw', 'raw_characters') }}
where json_data:biography.pronouns is not null