{# MACRO PARA GENERAR IDs ÚNICOS LLAMANDO A CLEAN_TEXT #}

{% macro generate_marvel_id(field_list) -%}
    {# 1. Aseguramos que sea una lista para poder iterar #}
    {%- set field_list = [field_list] if field_list is string else field_list -%}
    
    {# 2. Creamos la lista de campos ya limpios usando la otra macro #}
    {%- set cleaned_fields = [] -%}
    {%- for field in field_list -%}
        {# Inyectamos el resultado de la macro clean_text #}
        {%- do cleaned_fields.append(clean_text(field)) -%}
    {%- endfor -%}

    {# 3. Generamos el hash con dbt_utils #}
    {{ dbt_utils.generate_surrogate_key(cleaned_fields) }}
{%- endmacro %}