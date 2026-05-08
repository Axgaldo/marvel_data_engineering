--stg_character_affiliations.sql

with source as (
    select 
        json_data:char_id::int as character_id,
        json_data:affiliations as aff_json
    from {{ source('marvel_raw', 'raw_characters') }}
)

select
    character_id,
    team.value:name::string as team_name,
    -- Extraemos si es 'former' o 'current' del nombre de la llave
    case 
        when f.key contains 'former' then 'FORMER'
        when f.key contains 'current' then 'CURRENT'
        else 'UNKNOWN'
    end as affiliation_status,
    team.value:url::string as team_url
from source,
lateral flatten(input => aff_json) f,
lateral flatten(input => f.value) team