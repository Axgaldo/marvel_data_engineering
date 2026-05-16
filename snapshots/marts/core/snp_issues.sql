{% snapshot snp_issues %}

{{
    config(
      unique_key='issue_id',
      strategy='timestamp',
      updated_at='loaded_at',
      invalidate_hard_deletes=True
    )
}}

select * from {{ ref('stg_issues') }}

{% endsnapshot %}