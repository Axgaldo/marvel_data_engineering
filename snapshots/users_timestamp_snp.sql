{% snapshot users_timestamp_snp %}

{{
    config(
        database='DBT_TEST_SILVER_DB',
        target_schema='snapshots',
        unique_key='DNI',
        strategy='timestamp',
        updated_at='fecha_alta_sistema'
    )
}}

SELECT
    Nombre,
    DNI,
    email,
    fecha_alta_sistema
FROM {{ source('GOOGLE_SHEETS_SCD', 'users') }}

{% endsnapshot %}