--stg_characters.sql

with source as (
    select * from {{ source('marvel_raw', 'raw_characters') }}
),

extracted as (
    select
        -- Identificadores básicos
        json_data:char_id::int as character_id,
        json_data:name::string as character_name,
        json_data:image::string as image_url,
        
        -- FKs a tablas maestras (Normalización)
        {{ generate_marvel_id("json_data:biography.franchise") }} as franchise_id,
        {{ generate_marvel_id("json_data:metadata.universe") }} as universe_id,
        {{ generate_marvel_id("json_data:biography.species") }} as species_id,
        {{ generate_marvel_id("json_data:biography.pronouns") }} as pronouns_id,
        
        -- Entidad Multiversal Ancla (Coalesce para que si no tiene alter ego, el "multiversal" es su propio nombre)
        {{ generate_marvel_id("coalesce(json_data:is_alter_ego_of.name::string, json_data:name::string)") }} as multiversal_entity_id,

        -- Atributos de Biografía

        upper(json_data:biography.living_status::string) as living_status, --valores posibles: ALIVE, DEAD, UNDEAD

        --(json_data:biography.living_status::string ilike 'Alive') as is_alive,
        json_data:biography.franchise::string as franchise_name,
        json_data:metadata.universe::string as universe_name,
        json_data:biography.occupation::string as occupation,
        json_data:biography.place_of_origin::string as place_of_origin,

        -- Lógica de Años Activos (1940 - 2026)
        try_to_number(split_part(json_data:metadata.years_active::string, ' - ', 1)) as active_since_year,

        nullif(try_to_number(split_part(json_data:metadata.years_active::string, ' - ', 2)), 2026) as active_until_year,

        -- Primera Aparición (Regex)
        json_data:biography.first_appearance[0].issue::string as first_appearance_name,
        regexp_substr(
            json_data:biography.first_appearance[0].url::string, 
            '/comic/([0-9]+)', 1, 1, 'e'
        )::int as first_appearance_issue_id,

        -- BOOLEANOS PARA LA CAPA GOLD:
        --(try_to_number(split_part(json_data:metadata.years_active::string, ' - ', 2)) = 2026) as is_currently_active,
        --(json_data:biography.living_status::string ilike 'Alive') as is_alive,

        ingested_at as loaded_at
    from source
)

select * from extracted
-- WHERE living_status is not null and not (living_status like 'Alive') and not (living_status like 'Dead')  and not (living_status like 'Undead') 