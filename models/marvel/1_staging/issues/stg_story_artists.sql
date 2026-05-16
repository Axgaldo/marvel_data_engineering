-- stg_story_artists.sql

with expanded_roles as (
    select
        try_to_number(json_data:comic_id::string) as issue_id,
        s.index as story_index,
        -- Aquí limpias el contenido para que se vea bien en la tabla
        {{ clean_text('c.value:name') }} as artist_name,
        {{ clean_text('r.value::string') }} as role_name
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) s,
    lateral flatten(input => s.value:creators) c,
    -- Usamos split de Snowflake y flatten para roles múltiples (ej: "Writer, Artist")
    lateral flatten(input => split(c.value:role, ',')) r
)

select
    -- PK de la historia (compuesta por issue e índice)
    {{ dbt_utils.generate_surrogate_key(['issue_id', 'story_index']) }} as story_id,
    
    -- FK al artista (usando la columna ya limpia)
    {{ dbt_utils.generate_surrogate_key(['artist_name']) }} as artist_id,
    
    -- FK al rol (usando la columna ya limpia)
    {{ dbt_utils.generate_surrogate_key(['role_name']) }} as role_id,

    artist_name,
    role_name,
    
    current_timestamp() as loaded_at
from expanded_roles
where artist_name is not null