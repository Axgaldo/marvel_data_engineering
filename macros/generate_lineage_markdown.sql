-- macros/generate_lineage_markdown.sql

{% macro generate_lineage_markdown() %}
  {%- set manifest = get_manifest() -%}
  
  {%- set lineage_md -%}
# Data Lineage - Marvel Project

Generated on: {{ now() }}

## All Models

| Model | Type | Materialization | Depends On |
|-------|------|-----------------|-----------|
{%- for node in manifest.nodes.values() | sort(attribute='name') -%}
  {%- if node.resource_type in ('model', 'snapshot') and node.package_name == 'marvel_project' -%}
| {{ node.name }} | {{ node.resource_type }} | {{ node.config.materialized }} | {{ node.depends_on.nodes | map(attribute='name') | join(', ') | replace('model.marvel_project.', '') }} |
  {%- endif -%}
{%- endfor %}

## Staging Models (Silver Layer)

{%- set staging = manifest.nodes.values() | selectattr('path', 'search', 'staging') | list -%}
{%- for node in staging | sort(attribute='name') %}
- **{{ node.name }}**: {{ node.description | default('No description') }}
{%- endfor %}

## Dimension Models (Gold Layer)

{%- set dims = manifest.nodes.values() | selectattr('name', 'match', '^dim_') | list -%}
{%- for node in dims | sort(attribute='name') %}
- **{{ node.name }}**: {{ node.description | default('No description') }}
{%- endfor %}

## Fact Models (Gold Layer)

{%- set facts = manifest.nodes.values() | selectattr('name', 'match', '^fct_') | list -%}
{%- for node in facts | sort(attribute='name') %}
- **{{ node.name }}**: {{ node.description | default('No description') }}
{%- endfor %}

## Snapshots (SCD2 Models)

{%- set snps = manifest.nodes.values() | selectattr('resource_type', 'equalto', 'snapshot') | list -%}
{%- for node in snps | sort(attribute='name') %}
- **{{ node.name }}**: {{ node.description | default('No description') }}
{%- endfor %}
  {%- endset -%}
  
  {%- do print(lineage_md) -%}
  
  {%- if execute -%}
    {%- do log(lineage_md, info=true) -%}
  {%- endif -%}
  
{% endmacro %}