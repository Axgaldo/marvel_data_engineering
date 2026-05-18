--stg_characters.sql

with source as (
    select * from {{ source('marvel_raw', 'raw_characters') }}
),

extracted as (
    select
        -- Identificadores básicos
        json_data:char_id::int as character_id,
        {{ clean_text('json_data:name') }} as character_name,
        case
            when json_data:image::string like 'http%' then json_data:image::string
            else null
        end as image_url,
        
        -- FKs a tablas maestras (Normalización)
        {{ generate_marvel_id("json_data:biography.franchise") }} as franchise_id,
        {{ generate_marvel_id("json_data:metadata.universe") }} as universe_id,
        case 
            when json_data:biography.pronouns is not null 
            then {{ generate_marvel_id("replace(json_data:biography.pronouns::string, ' ', '/')") }}
            else null 
        end as pronouns_id,
        
        -- Entidad Multiversal Ancla (Coalesce para que si no tiene alter ego, el "multiversal" es su propio nombre)
        {{ generate_marvel_id("coalesce(json_data:is_alter_ego_of.name, json_data:name)") }} as multiversal_entity_id,

        -- Atributos de Biografía

        {{ clean_text('json_data:biography.living_status') }} as living_status, --valores posibles: ALIVE, DEAD, UNDEAD

        -- Lógica de Años Activos (1940 - 2026)
        try_to_number(split_part(json_data:metadata.years_active::string, ' - ', 1)) as active_since_year,

        nullif(try_to_number(split_part(json_data:metadata.years_active::string, ' - ', 2)), 2026) as active_until_year,

        -- Primera Aparición (Regex)
        json_data:biography.first_appearance[0].issue::string as first_appearance_name,
        regexp_substr(
            json_data:biography.first_appearance[0].url::string, 
            '/comic/([0-9]+)', 1, 1, 'e'
        )::int as first_appearance_issue_id,
        
        ingested_at as loaded_at
    from source
)

select * from extracted
-- WHERE living_status is not null and not (living_status like 'Alive') and not (living_status like 'Dead')  and not (living_status like 'Undead') 