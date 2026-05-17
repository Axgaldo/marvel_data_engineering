-- Test: Validar coherencia de métricas en fct_artist_performance
-- Checks: price * owners = estimated_market_revenue, quality_per_page_ratio coherente, etc

select
    issue_id,
    case 
        -- Test 1: estimated_market_revenue debe ser price * num_user_owns
        when abs(estimated_market_revenue - (price_dollars * total_owners)) > 0.01
        then 'FAIL: estimated_market_revenue calculation error'
        
        -- Test 2: quality_per_page_ratio debe estar entre 0 y (rating_max / min_pages)
        when quality_per_page_ratio < 0 or (quality_per_page_ratio > 10 and num_pages > 0)
        then 'FAIL: quality_per_page_ratio out of bounds'
        
        -- Test 3: artist_impact_score debe ser positivo
        when artist_impact_score < 0
        then 'FAIL: artist_impact_score is negative'
        
        -- Test 4: artist_impact_score no debe exceder reads + owns (sin ponderación)
        when artist_impact_score > (coalesce(total_readers, 0) + coalesce(total_owners, 0))
        then 'FAIL: artist_impact_score exceeds theoretical maximum'
        
        -- Test 5: issue_rating debe estar entre 0 y 10
        when issue_rating < 0 or issue_rating > 10
        then 'FAIL: issue_rating out of valid range (0-10)'
        
        -- Test 6: num_pages debe ser positivo si existe
        when num_pages is not null and num_pages <= 0
        then 'FAIL: num_pages must be positive'
        
        -- Test 7: price_dollars no debe ser negativo
        when price_dollars < 0
        then 'FAIL: price_dollars is negative'
        
        -- Test 8: Los contadores de usuarios no deben ser negativos
        when total_owners < 0 or total_readers < 0 or total_wishers < 0
        then 'FAIL: user counters are negative'
        
        -- Test 8: Los contadores de usuarios no deben ser negativos
        when engagement_index > 0
        then 'FAIL: user counters are negative'
        
        -- Test 8: Los contadores de usuarios no deben ser negativos
        when weighted_engagement_score > 0
        then 'FAIL: user counters are negative'
        
        else 'PASS'
    end as validation_result

from {{ ref('fct_issue_contributions') }}

where validation_result != 'PASS'