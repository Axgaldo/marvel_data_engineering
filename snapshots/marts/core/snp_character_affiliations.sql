{% snapshot snp_character_affiliations %}

{{
    config(
      unique_key="character_id || '-' || team_id",
      strategy='check',
      check_cols=['is_current'],
      invalidate_hard_deletes=True
    )
}}

select * from {{ ref('stg_character_affiliations') }}

{% endsnapshot %}