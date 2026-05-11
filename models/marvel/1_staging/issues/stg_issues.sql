--stg_issues.sql

with comics_source as (
    select * from {{ source('marvel_raw', 'raw_comics') }}
),

-- Traemos las fechas de lanzamiento como un CTE para el JOIN
release_dates_source as (
    select 
        json_data:comic_id::int as issue_id,
        json_data:release_date_raw::string as release_date_raw,
        json_data:series_id::int as series_id
    from {{ source('marvel_raw', 'raw_release_dates') }}
    -- Aquí ya no hace falta el WHERE estricto, el LEFT JOIN gestionará los nulos
),

flattened as (
    select
        -- Identificadores
        c.json_data:comic_id::int as issue_id,
        c.json_data:issue_url::string as issue_url,
        
        -- Datos de Release Dates (integrados)
        r.series_id,
        r.release_date_raw,
        
        -- Información de Cabecera
        c.json_data:title::string as issue_title,
        c.json_data:cover_url::string as cover_url,
        c.json_data:description::string as description,
        
        -- Ratings
        nullif(c.json_data:rating_avg::string, '0')::float as rating_avg,
        c.json_data:ratings_count::int as ratings_count,
        
        -- Estadísticas
        c.json_data:stats.have::int as num_user_owns,
        c.json_data:stats.read::int as num_user_reads,
        c.json_data:stats.wish::int as num_user_wishes,
        
        -- Detalles técnicos
        c.json_data:details.format::string as format_desc,
        c.json_data:details.pages::int as num_pages,
        replace(c.json_data:details.price::string, '$', '')::decimal(8,2) as price_dollars,
        
        c.json_data:details.upc::string as upc,
        c.json_data:details.sku::string as sku,
        c.json_data:details.cover_date::string as cover_date_raw,
        
        c.ingested_at as loaded_at
        
    from comics_source c
    left join release_dates_source r
        on c.json_data:comic_id::int = r.issue_id
)

select * from flattened