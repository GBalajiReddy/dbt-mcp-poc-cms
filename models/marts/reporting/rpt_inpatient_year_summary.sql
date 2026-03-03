{{ config(materialized='view') }}

select
    data_year,
    sum(total_discharges) as total_discharges,
    avg(average_covered_charges) as avg_covered_charges,
    avg(average_total_payments) as avg_total_payments,
    avg(average_medicare_payments) as avg_medicare_payments
from {{ ref('fct_inpatient_charges') }}
group by data_year
order by data_year