-- stg_roles.sql

with raw_roles as (
    select distinct {{ clean_text('r.value') }} as role_name
    from {{ source('marvel_raw', 'raw_comics') }},
    lateral flatten(input => json_data:stories) s,
    lateral flatten(input => s.value:creators) c,
    lateral flatten(input => split(c.value:role, ',')) r
)

select
    {{ generate_marvel_id("role_name") }} as role_id,
    role_name as role_description,
    current_timestamp() as loaded_at
from raw_roles
where role_name is not null