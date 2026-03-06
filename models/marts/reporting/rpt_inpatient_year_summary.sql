{{ config(materialized='view') }}

select
    data_year,
    to_date(data_year || '-01-01') as metric_year,

    sum(total_discharges) as total_discharges,

    sum(average_covered_charges * total_discharges)
        / nullif(sum(total_discharges), 0) as avg_covered_charges,

    sum(average_total_payments * total_discharges)
        / nullif(sum(total_discharges), 0) as avg_total_payments,

    sum(average_medicare_payments * total_discharges)
        / nullif(sum(total_discharges), 0) as avg_medicare_payments

from {{ ref('fct_inpatient_charges') }}

group by data_year
order by data_year