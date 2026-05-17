{% snapshot snp_issues %}

{{
    config(
      unique_key='issue_id',
      strategy='check',
      check_cols='all',
      hard_deletes='invalidate'
    )
}}

select * from {{ ref('stg_issues') }}

{% endsnapshot %}