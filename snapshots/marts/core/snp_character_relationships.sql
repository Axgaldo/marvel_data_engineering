{% snapshot snp_character_relationships %}

{{
    config(
      unique_key="character_id || '-' || relative_id || '-' || relationship_context",
      strategy='check',
      check_cols='all',
      hard_deletes='invalidate'
    )
}}

select * from {{ ref('stg_character_relationships') }}

{% endsnapshot %}