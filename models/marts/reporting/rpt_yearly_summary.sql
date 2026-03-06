{{ config(materialized='view') }}

with inpatient as (

    select
        data_year,
        'inpatient' as service_type,

        -- base measures
        sum(total_discharges) as total_discharges,

        sum(average_covered_charges * total_discharges)
            / nullif(sum(total_discharges), 0) as avg_covered_charges,

        sum(average_total_payments * total_discharges)
            / nullif(sum(total_discharges), 0) as avg_total_payments,

        sum(average_medicare_payments * total_discharges)
            / nullif(sum(total_discharges), 0) as avg_medicare_payments,

        -- outpatient placeholders
        cast(null as number(18,2)) as outpatient_services,
        cast(null as number(18,2)) as avg_estimated_submitted_charges

    from {{ ref('fct_inpatient_charges') }}
    group by 1,2

),

outpatient as (

    select
        data_year,
        'outpatient' as service_type,

        -- inpatient placeholders
        cast(null as number(18,2)) as total_discharges,
        cast(null as number(18,2)) as avg_covered_charges,

        -- base measures
        sum(average_total_payments * outpatient_services)
            / nullif(sum(outpatient_services), 0) as avg_total_payments,

        sum(average_medicare_payments * outpatient_services)
            / nullif(sum(outpatient_services), 0) as avg_medicare_payments,

        sum(outpatient_services) as outpatient_services,

        sum(average_estimated_submitted_charges * outpatient_services)
            / nullif(sum(outpatient_services), 0) as avg_estimated_submitted_charges

    from {{ ref('fct_outpatient_charges') }}
    group by 1,2

)

select * from inpatient
union all
select * from outpatient