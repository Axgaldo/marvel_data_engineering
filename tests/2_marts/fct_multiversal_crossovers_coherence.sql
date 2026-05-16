-- Test: Validar coherencia de métricas en fct_multiversal_crossovers
-- Checks: story_complexity_index, is_multiversal_event coherentes

select
    issue_id,
    total_characters_present,
    total_universes_involved,
    is_multiversal_event,
    story_complexity_index,
    case 
        -- Test 1: story_complexity_index = characters * universes
        when story_complexity_index != (total_characters_present * total_universes_involved)
        then 'FAIL: story_complexity_index calculation error'
        
        -- Test 2: is_multiversal_event debe ser true si universos > 1
        when (total_universes_involved > 1 and is_multiversal_event = false)
        then 'FAIL: is_multiversal_event should be true for multiple universes'
        
        -- Test 3: is_multiversal_event debe ser false si universos = 1
        when (total_universes_involved = 1 and is_multiversal_event = true)
        then 'FAIL: is_multiversal_event should be false for single universe'
        
        -- Test 4: story_complexity_index debe ser >= 1
        when story_complexity_index < 1
        then 'FAIL: story_complexity_index must be >= 1'
        
        -- Test 5: total_characters_present y total_universes_involved deben ser positivos
        when total_characters_present <= 0 or total_universes_involved <= 0
        then 'FAIL: counts must be positive'
        
        else 'PASS'
    end as validation_result

from {{ ref('fct_multiversal_crossovers') }}

where validation_result != 'PASS'