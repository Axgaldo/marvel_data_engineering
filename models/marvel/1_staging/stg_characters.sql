{{ config(database='MARVEL_BRONZE_DB', schema='STAGING') }}

with source as (
    select * from {{ source('marvel_raw', 'raw_characters') }}
),

extracted as (
    select
        json_data:char_id::int as character_id,
        json_data:name::string as character_name,
        
        -- FKs a tablas Maestras
        md5(lower(nullif(json_data:is_alter_ego_of.name::string, ''))) as multiversal_entity_id,
        md5(lower(json_data:biography.species::string)) as species_id,
        md5(lower(json_data:biography.pronouns::string)) as pronouns_id,

        json_data:metadata.universe::string as universe,
        json_data:biography.living_status::string as living_status,
        json_data:biography.mantle::string as mantle,

        -- EXTRACCIÓN DE IDS DESDE URL (Regex)
        -- patrón /comic/ seguido de dígitos
        json_data:biography.first_appearance[0].issue::string as first_appearance_name,
        regexp_substr(
            json_data:biography.first_appearance[0].url::string, 
            '/comic/([0-9]+)', 1, 1, 'e'
        )::int as first_appearance_issue_id,

        json_data:biography.death[0].issue::string as death_issue_name,
        regexp_substr(
            json_data:biography.death[0].url::string, 
            '/comic/([0-9]+)', 1, 1, 'e'
        )::int as death_issue_id,

        ingested_at as loaded_at
    from source
)

select * from extracted