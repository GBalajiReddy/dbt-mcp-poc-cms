{{ config(materialized='view') }}

select
    data_year,
    sum(outpatient_services) as total_outpatient_services,
    avg(average_estimated_submitted_charges) as avg_estimated_submitted_charges,
    avg(average_total_payments) as avg_total_payments
from {{ ref('fct_outpatient_charges') }}
group by data_year
order by data_year