{% snapshot snp_characters %}

{{
    config(
      unique_key='character_id',
      strategy='check',
      check_cols=[
        'character_name',
        'image_url',
        'franchise_id',
        'universe_id',
        'pronouns_id',
        'multiversal_entity_id',
        'living_status',
        'active_since_year',
        'active_until_year',
        'first_appearance_name',
        'first_appearance_issue_id'
      ],
      hard_deletes='invalidate'
    )
}}

select *
from {{ ref('stg_characters') }}

{% endsnapshot %}