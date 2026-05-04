{% snapshot users_check_snp %}

{{
    config(
        database='DBT_TEST_SILVER_DB',
        target_schema='snapshots',
        unique_key='DNI',
        strategy='check',
        check_cols=['Nombre', 'email']
    )
}}

SELECT
    Nombre,
    DNI,
    email,
    fecha_alta_sistema
FROM {{ source('GOOGLE_SHEETS_SCD', 'users') }}

{% endsnapshot %}