{% snapshot snp_character_affiliations %}

{{
    config(
      unique_key='character_id || team_id',
      strategy='timestamp',
      updated_at='loaded_at',
      invalidate_hard_deletes=True
    )
}}

select * from {{ ref('stg_character_affiliations') }}

{% endsnapshot %}