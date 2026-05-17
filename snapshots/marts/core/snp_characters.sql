{% snapshot snp_characters %}

{{
    config(
      unique_key='character_id',
      strategy='check',
      check_cols='all',
      hard_deletes='invalidate'
    )
}}

select * from {{ ref('stg_characters') }}

{% endsnapshot %}