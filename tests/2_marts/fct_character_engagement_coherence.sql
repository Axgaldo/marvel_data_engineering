-- tests/marts/fct_character_engagement_coherence.sql

select 
    engagement_pk,
    character_id,
    issue_id,
    appearance_type,
    engagement_index,
    weighted_engagement_score
from {{ ref('fct_character_engagement') }}
where 
    -- Solo validar lo ESTRICTAMENTE NECESARIO
    engagement_index < 0  -- No puede ser negativo
    or weighted_engagement_score < 0  -- No puede ser negativo