--stg_issues.sql

with comics_source as (
    select * from {{ source('marvel_raw', 'raw_comics') }}
),

release_dates_source as (
    select 
        try_to_number(json_data:comic_id::string) as issue_id,
        json_data:release_date_raw::string as release_date_raw,
        try_to_number(json_data:series_id::string) as series_id
    from {{ source('marvel_raw', 'raw_release_dates') }}
),

flattened as (
    select
        -- Identificadores nativos de Snowflake
        try_to_number(c.json_data:comic_id::string) as issue_id,
        c.json_data:issue_url::string as issue_url,
        
        -- Datos de Release Dates
        r.series_id,
        r.release_date_raw,
        
        -- Información de Cabecera
        c.json_data:title::string as issue_title,
        c.json_data:cover_url::string as cover_url,
        c.json_data:description::string as description,
        
        -- Ratings (si el rating_avg es 0 lo ponemos null porque no es válido )
        nullif(try_to_decimal(c.json_data:rating_avg::string, 4, 2), 0) as rating_avg,
        try_to_number(c.json_data:ratings_count::string) as ratings_count,
        
        -- Estadísticas (Limpieza de comas + TRY_TO_NUMBER)
        try_to_number(replace(c.json_data:stats.have::string, ',', '')) as num_user_owns,
        try_to_number(replace(c.json_data:stats.read::string, ',', '')) as num_user_reads,
        try_to_number(replace(c.json_data:stats.wish::string, ',', '')) as num_user_wishes,
        
        -- Detalles técnicos
        {{ generate_marvel_id("c.json_data:details.format::string") }} as format_id,
        try_to_number(c.json_data:details.pages::string) as num_pages,
        
        -- Precios (Limpieza de '$' + TRY_TO_DECIMAL)
        try_to_decimal(replace(c.json_data:details.price::string, '$', ''), 8, 2) as price_dollars,
        
        c.json_data:details.upc::string as upc,
        c.json_data:details.sku::string as sku,
        c.json_data:details.cover_date::string as cover_date_raw,
        
        c.ingested_at as loaded_at
        
    from comics_source c
    left join release_dates_source r
        on try_to_number(c.json_data:comic_id::string) = r.issue_id
)

select * from flattened