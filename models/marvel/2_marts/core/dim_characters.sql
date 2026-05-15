with current_chars as (
    select * from {{ ref('snp_characters') }}
    where dbt_valid_to is null
),
franchises as (select * from {{ ref('stg_franchises') }}),
universes as (select * from {{ ref('stg_universes') }}),
pronouns as (select * from {{ ref('stg_pronouns') }}),
entities as (select * from {{ ref('stg_multiversal_entities') }}),
species_agg as (
    select 
        cs.character_id::string as character_id, -- Forzamos string aquí
        listagg(s.species_name, ', ') within group (order by s.species_name) as species_list
    from {{ ref('stg_character_species') }} cs
    join {{ ref('stg_species') }} s on cs.species_id = s.species_id
    group by 1
)

select
    c.character_id::string as character_id, -- String para ser compatible con los hechos
    c.character_name,
    f.franchise_name,
    u.universe_name,
    p.pronouns_desc,
    e.multiversal_entity_name,
    c.living_status, -- ALIVE, DEAD OR UNDEAD
    c.active_since_year,
    coalesce(c.active_until_year, 2026) as last_active_year,
    case when c.active_until_year is null then true else false end as is_currently_active,
    c.first_appearance_name,
    c.first_appearance_issue_id,
    c.image_url,
    coalesce(sp.species_list, 'UNKNOWN') as species_list,
    -- Metadatos SCD2
    c.dbt_valid_from as record_valid_from,
    c.dbt_updated_at as last_version_update
from current_chars c
-- CORRECCIÓN: c.franchise_id en lugar de c.character_id para el join de franquicias
left join franchises f on c.franchise_id = f.franchise_id 
left join universes u on c.universe_id = u.universe_id
left join pronouns p on c.pronouns_id = p.pronouns_id
left join entities e on c.multiversal_entity_id = e.multiversal_entity_id
-- Forzamos string en el join de especies para evitar el error 22018
left join species_agg sp on c.character_id::string = sp.character_id::string