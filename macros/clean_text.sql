{# MACRO PARA ESTANDARIZAR FORMATO DE TEXTO #}

{% macro clean_text(texto) -%}

    upper(trim(nullif(cast({{ texto }} as string), '')))
    
{%- endmacro %}