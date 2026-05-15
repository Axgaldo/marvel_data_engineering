with artists as (
    select * from {{ ref('stg_artists') }}
)

select
    artist_id,
    artist_name,
    loaded_at
from artists