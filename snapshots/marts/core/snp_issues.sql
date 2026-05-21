{% snapshot snp_issues %}

{{
    config(
      unique_key='issue_id',
      strategy='check',
      check_cols=[
        'issue_url',
        'series_id',
        'release_date',
        'issue_title',
        'cover_url',
        'description',
        'rating_avg',
        'ratings_count',
        'num_user_owns',
        'num_user_reads',
        'num_user_wishes',
        'format_id',
        'num_pages',
        'price_dollars',
        'upc',
        'sku',
        'cover_date'
      ],
      hard_deletes='invalidate'
    )
}}

select *
from {{ ref('stg_issues') }}

{% endsnapshot %}