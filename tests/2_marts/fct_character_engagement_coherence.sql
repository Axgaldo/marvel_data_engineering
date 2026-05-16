-- Test: Validar coherencia de métricas en fct_character_engagement
-- Checks: engagement_index y weighted_engagement_score sean coherentes

select
    engagement_pk,
    character_id,
    issue_id,
    appearance_type,
    case 
        -- Test 1: engagement_index debe ser reads*0.5 + owns*0.3 + wishes*0.2
        when abs(coalesce(engagement_index, 0) - 
                 (coalesce(num_user_reads, 0) * 0.5 + coalesce(num_user_owns, 0) * 0.3 + coalesce(num_user_wishes, 0) * 0.2)) > 0.01
        then 'FAIL: engagement_index calculation error'
        
        -- Test 2: weighted_engagement_score debe ser positivo
        when weighted_engagement_score < 0
        then 'FAIL: weighted_engagement_score is negative'
        
        -- Test 3: weighted_engagement_score máximo debe respetar appearance_type multiplier
        when appearance_type = 'PRIMARY' and weighted_engagement_score > (coalesce(num_user_reads, 0) * 0.5 + coalesce(num_user_owns, 0) * 0.3) * 1.0
        then 'FAIL: PRIMARY weighted_engagement_score exceeds max'
        when appearance_type = 'SUPPORTING' and weighted_engagement_score > (coalesce(num_user_reads, 0) * 0.5 + coalesce(num_user_owns, 0) * 0.3) * 0.5
        then 'FAIL: SUPPORTING weighted_engagement_score exceeds max'
        when appearance_type = 'CAMEO' and weighted_engagement_score > (coalesce(num_user_reads, 0) * 0.5 + coalesce(num_user_owns, 0) * 0.3) * 0.1
        then 'FAIL: CAMEO weighted_engagement_score exceeds max'
        
        -- Test 4: rating_avg entre 0 y 10
        when rating_avg < 0 or rating_avg > 10
        then 'FAIL: rating_avg out of valid range (0-10)'
        
        -- Test 5: Contadores de usuarios no negativos
        when num_user_owns < 0 or num_user_reads < 0 or num_user_wishes < 0
        then 'FAIL: user counters are negative'
        
        -- Test 6: appearance_type debe ser válido
        when appearance_type not in ('PRIMARY', 'SUPPORTING', 'CAMEO')
        then 'FAIL: appearance_type has invalid value'
        
        else 'PASS'
    end as validation_result

from {{ ref('fct_character_engagement') }}

where validation_result != 'PASS'