-- stg_roles.sql

with raw_roles as (
    select distinct
    r.value as role_name_raw,
    ingested_at as loaded_at

    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) s,
    lateral flatten(input => s.value:creators) c,
    lateral flatten(input => split(c.value:role, ',')) r
)

select distinct
    {{ generate_marvel_id("role_name_raw") }} as role_id,
    {{ clean_text('role_name_raw') }}  as role_description,
    loaded_at
from raw_roles
where role_name_raw is not null