{% snapshot snp_character_relationships %}

{{
    config(
      unique_key="character_id || '-' || relative_id || '-' || relationship_context",
      strategy='check',
      check_cols=[
        'character_id',
        'relative_id',
        'relative_name',
        'relationship_context'
      ],
      hard_deletes='invalidate'
    )
}}

select *
from {{ ref('stg_character_relationships') }}

{% endsnapshot %}