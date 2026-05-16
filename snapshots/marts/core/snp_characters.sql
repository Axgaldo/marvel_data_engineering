{% snapshot snp_characters %}

{{
    config(
      unique_key='character_id',
      strategy='timestamp',
      updated_at='loaded_at',
      invalidate_hard_deletes=True
    )
}}

select * from {{ ref('stg_characters') }}

{% endsnapshot %}