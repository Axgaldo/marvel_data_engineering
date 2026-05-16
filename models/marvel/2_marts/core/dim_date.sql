with raw_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('1939-01-01' as date)",
        end_date="dateadd(year, 10, current_date())"
    ) }}
),

final as (
    select
        -- dbt_utils.date_spine devuelve un timestamp. 
        -- Lo convertimos a DATE para evitar errores en las funciones posteriores.
        cast(date_day as date) as date_id,
        year(date_id) as year,
        month(date_id) as month,
        day(date_id) as day,
        quarter(date_id) as quarter,
        monthname(date_id) as month_name,
        dayname(date_id) as day_name,
        
        case 
            when year(date_id) between 1939 and 1950 then 'Golden Age'
            when year(date_id) between 1956 and 1970 then 'Silver Age'
            when year(date_id) between 1970 and 1985 then 'Bronze Age'
            when year(date_id) >= 1985 then 'Modern Age'
            else 'Other'
        end as marvel_era
    from raw_spine
)

select * from final
