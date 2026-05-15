with current_memberships as (
    select * from {{ ref('snp_character_affiliations') }}
    where dbt_valid_to is null
),
teams_master as (
    select * from {{ ref('stg_teams') }}
),
characters_master as (
    select character_id, character_name from {{ ref('stg_characters') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['m.character_id', 'm.team_id']) }} as membership_key,
    m.character_id,
    m.team_id,
    c.character_name,
    t.team_name,
    m.is_current as is_active_member,
    -- Metadatos SCD2
    m.dbt_valid_from as joined_at_timestamp,
    m.dbt_updated_at as last_membership_update
from current_memberships m
left join teams_master t on m.team_id = t.team_id
left join characters_master c on m.character_id = c.character_id