{# MACRO PARA TEXTOS (TITULOS, NOMBRES, ETC) #}

{% macro generate_marvel_id(field_list) -%}
    {# 
       1. Convertimos el input en lista si es un solo campo.
       2. Aplicamos NULLIF para tratar strings vacíos como nulos.
       3. Aplicamos LOWER y TRIM para estandarizar.
    #}
    {%- set cleaned_fields = [] -%}
    
    {%- if field_list is string -%}
        {%- set field_list = [field_list] -%}
    {%- endif -%}

    {%- for field in field_list -%}
        {%- do cleaned_fields.append("lower(trim(nullif(cast(" ~ field ~ " as string), '')))") -%}
    {%- endfor -%}

    {{ dbt_utils.generate_surrogate_key(cleaned_fields) }}
{%- endmacro %}