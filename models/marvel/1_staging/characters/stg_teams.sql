-- stg_teams.sql

with source as (
    select 
        json_data:affiliations as aff_json
    from {{ source('marvel_raw', 'raw_characters') }}
),

flattened_teams as (
    select distinct
        {{ clean_text('team.value:name') }} as team_name
    from source,
    lateral flatten(input => aff_json) f,
    lateral flatten(input => f.value) team
)

select
    -- La macro genera el mismo ID que en la tabla de afiliaciones
    {{ generate_marvel_id("team_name") }} as team_id,
    team_name,
    
    current_timestamp() as loaded_at
from flattened_teams
where team_name is not null