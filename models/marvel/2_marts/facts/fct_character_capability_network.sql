-- models/marvel/2_marts/facts/fct_character_capability_network.sql

{{
  config(
    materialized='incremental',
    unique_key=['character_id', 'capability_name'],
    on_schema_change='fail'
  )
}}

with character_caps as (
    select
        cc.character_id,
        cc.capability_id,
        c.capability_name,
        c.is_super_power,
        cc.loaded_at
    from {{ ref('stg_character_capabilities') }} cc
    join {{ ref('stg_capabilities') }} c on cc.capability_id = c.capability_id
    {% if is_incremental() %}
        where cc.loaded_at > (select coalesce(max(loaded_at), '1900-01-01') from {{ this }})
    {% endif %}
),

capability_sharing_stats as (
    select
        cc1.capability_id,
        count(distinct cc2.character_id) as characters_with_capability
    from {{ ref('stg_character_capabilities') }} cc1
    left join {{ ref('stg_character_capabilities') }} cc2 on cc1.capability_id = cc2.capability_id
    group by 1
)

select
    cc.character_id,
    cc.capability_name,
    -- case when cc.is_super_power then 'SUPERPOWER' else 'SKILL' end as capability_type,
    cc.is_super_power,
    css.characters_with_capability,
    case 
        when css.characters_with_capability >= 10 then 'COMMON'
        when css.characters_with_capability >= 5 then 'UNCOMMON'
        when css.characters_with_capability >= 2 then 'RARE'
        else 'UNIQUE'
    end as capability_rarity,
    cc.loaded_at

from character_caps cc
left join capability_sharing_stats css on cc.capability_id = css.capability_id