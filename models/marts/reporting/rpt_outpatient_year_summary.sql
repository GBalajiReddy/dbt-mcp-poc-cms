{{ config(materialized='view') }}

select
    data_year,
    to_date(data_year || '-01-01') as metric_year,

    sum(outpatient_services) as total_outpatient_services,

    sum(average_estimated_submitted_charges * outpatient_services)
        / nullif(sum(outpatient_services), 0) as avg_estimated_submitted_charges,

    sum(average_total_payments * outpatient_services)
        / nullif(sum(outpatient_services), 0) as avg_total_payments,

    sum(average_medicare_payments * outpatient_services)
        / nullif(sum(outpatient_services), 0) as avg_medicare_payments

from {{ ref('fct_outpatient_charges') }}

group by data_year
order by data_year