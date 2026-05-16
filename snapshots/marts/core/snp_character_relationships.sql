{% snapshot snp_character_relationships %}

{{
    config(
      unique_key="character_id || '-' || relative_id || '-' || relationship_context",
      strategy='timestamp',
      updated_at='loaded_at',
      invalidate_hard_deletes=True
    )
}}

select * from {{ ref('stg_character_relationships') }}

{% endsnapshot %}