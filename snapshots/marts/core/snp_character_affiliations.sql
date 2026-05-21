{% snapshot snp_character_affiliations %}

{{
    config(
      unique_key="character_id || '-' || team_id",
      strategy='check',
      check_cols=[
        'character_id',
        'team_id',
        'is_current'
      ],
      hard_deletes='invalidate'
    )
}}

select *
from {{ ref('stg_character_affiliations') }}

{% endsnapshot %}