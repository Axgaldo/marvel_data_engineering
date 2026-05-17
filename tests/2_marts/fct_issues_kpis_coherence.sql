-- Test: coherencia de métricas en dim_issues

select
    issue_id,

    case

        /* rating válido */
        when rating_avg is not null
             and (rating_avg < 0 or rating_avg > 5)
        then 'FAIL: issue_rating out of range'

        /* usuarios negativos */
        when coalesce(num_user_reads,0) < 0
          or coalesce(num_user_owns,0) < 0
          or coalesce(num_user_wishes,0) < 0
        then 'FAIL: negative user metrics'

        /* páginas inválidas */
        when num_pages is not null and num_pages <= 0
        then 'FAIL: invalid num_pages'

        /* precio negativo */
        when price_dollars is not null and price_dollars < 0
        then 'FAIL: negative price'

        else 'PASS'

    end as validation_result

from {{ ref('dim_issues') }}

where validation_result != 'PASS'