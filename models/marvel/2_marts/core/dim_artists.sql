with artists as (
    select * from {{ ref('stg_artists') }}
)

select
    artist_id,
    artist_name
from artists