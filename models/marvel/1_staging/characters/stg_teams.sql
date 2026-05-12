-- stg_teams.sql

with source as (
    select 
        json_data:affiliations as aff_json
    from {{ source('marvel_raw', 'raw_characters') }}
),

flattened_teams as (
    select distinct
        team.value:name::string as team_name_raw
    from source,
    lateral flatten(input => aff_json) f,
    lateral flatten(input => f.value) team
)

select
    -- La macro genera el mismo ID que en la tabla de afiliaciones
    {{ generate_marvel_id("team_name_raw") }} as team_id,
    team_name_raw as team_name
from flattened_teams
where team_name is not null