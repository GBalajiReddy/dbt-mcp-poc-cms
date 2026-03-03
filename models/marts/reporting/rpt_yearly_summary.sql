{{ config(materialized='view') }}

with inpatient as (
    select
        data_year,
        'inpatient' as service_type,

        -- base measures
        sum(total_discharges) as total_discharges,
        avg(average_covered_charges) as avg_covered_charges,
        avg(average_total_payments) as avg_total_payments,
        avg(average_medicare_payments) as avg_medicare_payments,

        -- outpatient placeholders (keep schema aligned)
        cast(null as number) as outpatient_services,
        cast(null as number) as avg_estimated_submitted_charges
    from {{ ref('fct_inpatient_charges') }}
    group by 1,2
),

outpatient as (
    select
        data_year,
        'outpatient' as service_type,

        -- inpatient placeholders (keep schema aligned)
        cast(null as number) as total_discharges,
        cast(null as number) as avg_covered_charges,

        -- base measures
        avg(average_total_payments) as avg_total_payments,
        avg(average_medicare_payments) as avg_medicare_payments,
        sum(outpatient_services) as outpatient_services,
        avg(average_estimated_submitted_charges) as avg_estimated_submitted_charges
    from {{ ref('fct_outpatient_charges') }}
    group by 1,2
)

select * from inpatient
union all
select * from outpatient